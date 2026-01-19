module PC_reg(
    input wire clk, 
    input wire reset,
    input wire pc_in,
    input wire [31:0] bus,
    output wire [31:0] pc_val
);


    reg32 PC (
        .clk(clk),
        .reset(reset),
        .en(pc_in),
        .d_in(bus),
        .d_out(pc_val)
    );


endmodule