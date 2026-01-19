module PC_reg(
    input wire clk, 
    input wire reset,
    input wire pc_in,
    input wire [31:0] bus,
    output reg [31:0] pc_out
);


    reg32 PC (
        .clk(clk),
        .reset(reset),
        .en(pc_in),
        .d_in(bus),
        .d_out(pc_out)
    )


endmodule