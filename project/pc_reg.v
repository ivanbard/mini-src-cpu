// PC with increment (using adder, no + operator)

module pc_reg(
    input wire clk,
    input wire reset,
    input wire pc_in,
    input wire IncPC,
    input wire [31:0] BusMuxOut,
    output reg [31:0] pc_val
);

    wire [31:0] pc_plus_one;
    wire cout;
    
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
            pc_val <= BusMuxOut;
        end else if (IncPC) begin
            pc_val <= pc_plus_one;
        end
    end

endmodule
