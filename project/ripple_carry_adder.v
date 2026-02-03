// Ripple Carry Adder - 32-bit
// No + operator used - implements addition using full adders

module ripple_carry_adder(
    input wire [31:0] A,
    input wire [31:0] B,
    input wire Cin,
    output wire [31:0] Sum,
    output wire Cout
);

    wire [32:0] carry;
    assign carry[0] = Cin;

    // Generate 32 full adders
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

endmodule

// Full Adder - Single bit
module full_adder(
    input wire a,
    input wire b,
    input wire cin,
    output wire sum,
    output wire cout
);

    // Sum = a XOR b XOR cin
    assign sum = a ^ b ^ cin;
    
    // Cout = (a AND b) OR (cin AND (a XOR b))
    assign cout = (a & b) | (cin & (a ^ b));

endmodule
