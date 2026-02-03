// PC reg with increment
//supports: load from bus (pc_in) and increment (IncPC)
//uses ripple carry adder for increment (no + operator)

module pc_reg(
    input wire clk,
    input wire reset,
    input wire pc_in, // Load from bus
    input wire IncPC, // Increment PC by 1
    input wire [31:0] BusMuxOut,
    output reg [31:0] pc_val
);

    // use adder for increment (no + operator per requirements)
    wire [31:0] pc_plus_one;
    wire cout;  // unused carry out, may be needed later
    
    ripple_carry_adder inc_adder (
        .A(pc_val),
        .B(32'b1),
        .Cin(1'b0),
        .Sum(pc_plus_one),
        .Cout(cout)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_val <= 32'b0;
        end else if (pc_in) begin
            // load from bus has priority
            pc_val <= BusMuxOut;
        end else if (IncPC) begin
            // increment by 1
            pc_val <= pc_plus_one;
        end
    end

endmodule
