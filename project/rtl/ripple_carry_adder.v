// 32-bit ripple carry adder (no + operator)

module ripple_carry_adder(
    input wire [31:0] A,
    input wire [31:0] B,
    input wire Cin,
    output wire [31:0] Sum,
    output wire Cout,
<<<<<<< HEAD
    output wire Vout
=======
    output wire Overflow
>>>>>>> bce2a3c2b135366f152ddc5797cb6cec577ffd42
);

    wire [32:0] carry;
    assign carry[0] = Cin;

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : fa_gen
            full_adder fa (
                .a(A[i]),
                .b(B[i]),
                .cin(carry[i]),
                .sum(Sum[i]),
                .cout(carry[i + 1])
            );
        end
    endgenerate

    assign Cout = carry[32];
<<<<<<< HEAD
    assign Vout = carry[31] ^ carry[32];
=======
    assign Overflow = carry[31] ^ carry[32];
>>>>>>> bce2a3c2b135366f152ddc5797cb6cec577ffd42

endmodule

module full_adder(
    input wire a,
    input wire b,
    input wire cin,
    output wire sum,
    output wire cout
);

    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (cin & (a ^ b));

endmodule



// overflow, branch not taken test benches for each branch test case 
// 