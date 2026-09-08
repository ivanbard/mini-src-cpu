// 32-bit Mini SRC ALU with a 64-bit result path.
// no +/- operators except in mul/div units

module alu(
    input wire [31:0] A,
    input wire [31:0] B,
    input wire [4:0] op,
    output reg [63:0] C,
    output reg Overflow
);

    // Operation codes
    localparam OP_ADD  = 5'b00000;
    localparam OP_SUB  = 5'b00001;
    localparam OP_MUL  = 5'b00010;
    localparam OP_DIV  = 5'b00011;
    localparam OP_AND  = 5'b00100;
    localparam OP_OR   = 5'b00101;
    localparam OP_NOT  = 5'b00110;
    localparam OP_NEG  = 5'b00111;
    localparam OP_SHR  = 5'b01000;
    localparam OP_SHRA = 5'b01001;
    localparam OP_SHL  = 5'b01010;
    localparam OP_ROR  = 5'b01011;
    localparam OP_ROL  = 5'b01100;

    wire [31:0] add_result, sub_result;
    wire add_cout, sub_cout;
    wire add_overflow, sub_overflow;
    
    wire [63:0] mul_result;
    
    wire [31:0] div_quotient, div_remainder;
    
    wire [31:0] shr_result, shra_result, shl_result, ror_result, rol_result;
    
    wire [31:0] neg_result;
    wire neg_cout;

    ripple_carry_adder rca_add (
        .A(A),
        .B(B),
        .Cin(1'b0),
        .Sum(add_result),
        .Cout(add_cout),
        .Overflow(add_overflow)
    );

    // subtractor: A - B = A + (~B) + 1
    ripple_carry_adder rca_sub (
        .A(A),
        .B(~B),
        .Cin(1'b1),
        .Sum(sub_result),
        .Cout(sub_cout),
        .Overflow(sub_overflow)
    );

    // negation: -B = ~B + 1
    ripple_carry_adder rca_neg (
        .A(32'b0),
        .B(~B),
        .Cin(1'b1),
        .Sum(neg_result),
        .Cout(neg_cout),
        .Overflow()
    );

    booth_multiplier booth_mul (
        .A(A),
        .B(B),
        .Product(mul_result)
    );

    divider div_unit (
        .Dividend(A),
        .Divisor(B),
        .Quotient(div_quotient),
        .Remainder(div_remainder)
    );

    barrel_shifter shifter (
        .A(A),
        .B(B[4:0]),
        .shr_out(shr_result),
        .shra_out(shra_result),
        .shl_out(shl_result),
        .ror_out(ror_result),
        .rol_out(rol_result)
    );

    always @(*) begin
        Overflow = 1'b0;
        case (op)
            OP_ADD: begin C = {32'b0, add_result}; Overflow = add_overflow; end
            OP_SUB: begin C = {32'b0, sub_result}; Overflow = sub_overflow; end
            OP_MUL:  C = mul_result;
            OP_DIV:  C = {div_remainder, div_quotient};
            OP_AND:  C = {32'b0, A & B};
            OP_OR:   C = {32'b0, A | B};
            OP_NOT:  C = {32'b0, ~B};
            OP_NEG:  C = {32'b0, neg_result};
            OP_SHR:  C = {32'b0, shr_result};
            OP_SHRA: C = {32'b0, shra_result};
            OP_SHL:  C = {32'b0, shl_result};
            OP_ROR:  C = {32'b0, ror_result};
            OP_ROL:  C = {32'b0, rol_result};
            default: C = 64'b0;
        endcase
    end

endmodule
