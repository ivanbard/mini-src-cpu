// ALU for Mini SRC Processor - Phase 1
// Operations: ADD, SUB, MUL, DIV, AND, OR, NOT, NEG, SHR, SHRA, SHL, ROR, ROL
// NOTE: No +/- operators used except in MUL and DIV circuitry per project requirements

module alu(
    input wire [31:0] A,          // First operand (from Y register)
    input wire [31:0] B,          // Second operand (from bus)
    input wire [4:0] op,          // Operation select
    output reg [63:0] C           // 64-bit result (for MUL/DIV support)
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

    // Internal wires for adder/subtractor
    wire [31:0] add_result;
    wire [31:0] sub_result;
    wire add_cout, sub_cout;
    
    // Internal wires for multiplication (64-bit result)
    wire [63:0] mul_result;
    
    // Internal wires for division
    wire [31:0] div_quotient;
    wire [31:0] div_remainder;
    
    // Internal wires for shifter
    wire [31:0] shr_result;
    wire [31:0] shra_result;
    wire [31:0] shl_result;
    wire [31:0] ror_result;
    wire [31:0] rol_result;
    
    // Internal wire for negation (using adder)
    wire [31:0] neg_result;
    wire neg_cout;

    // Ripple carry adder (no + operator)
    ripple_carry_adder rca_add (
        .A(A),
        .B(B),
        .Cin(1'b0),
        .Sum(add_result),
        .Cout(add_cout)
    );

    // Subtractor: A - B = A + (~B) + 1 (using adder with inverted B and Cin=1)
    ripple_carry_adder rca_sub (
        .A(A),
        .B(~B),
        .Cin(1'b1),
        .Sum(sub_result),
        .Cout(sub_cout)
    );

    // Negation: -B = 0 + (~B) + 1 = ~B + 1
    ripple_carry_adder rca_neg (
        .A(32'b0),
        .B(~B),
        .Cin(1'b1),
        .Sum(neg_result),
        .Cout(neg_cout)
    );

    // Booth multiplier (32x32 with bit-pair recoding)
    booth_multiplier booth_mul (
        .A(A),
        .B(B),
        .Product(mul_result)
    );

    // Non-restoring divider
    divider div_unit (
        .Dividend(A),
        .Divisor(B),
        .Quotient(div_quotient),
        .Remainder(div_remainder)
    );

    // Barrel shifter
    barrel_shifter shifter (
        .A(A),
        .B(B[4:0]),  // Shift amount (0-31)
        .shr_out(shr_result),
        .shra_out(shra_result),
        .shl_out(shl_result),
        .ror_out(ror_result),
        .rol_out(rol_result)
    );

    // ALU output selection
    always @(*) begin
        case (op)
            OP_ADD:  C = {32'b0, add_result};
            OP_SUB:  C = {32'b0, sub_result};
            OP_MUL:  C = mul_result;
            OP_DIV:  C = {div_remainder, div_quotient};  // HI=remainder, LO=quotient
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
