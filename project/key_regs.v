module key_regs(
    input wire clk, 
    input wire reset,
    input wire [31:0] BusMuxOut,
    input wire pc_in,
    output wire [31:0] pc_val,
    input wire ir_in,
    output wire [31:0] ir_val,
    input wire y_in,
    output wire [31:0] y_val,
    input wire zhigh_in, //need 2 for because its 64-bit
    output wire [31:0] zhigh_val, 
    input wire zlow_in,
    output wire [31:0] zlow_val,
    input wire mar_in,
    output wire [31:0] mar_val,
    input wire hi_in,
    input wire lo_in,
    output wire [31:0] hi_val,
    output wire [31:0] lo_val
);

    reg32 PC (
        .clk(clk),
        .reset(reset),
        .en(pc_in),
        .d_in(bus),
        .d_out(pc_val)
    );

    reg32 IR (
        .clk(clk),
        .reset(reset),
        .en(ir_in),
        .d_in(bus),
        .d_out(ir_val)
    );

    reg32 Y (
        .clk(clk),
        .reset(reset),
        .en(y_in),
        .d_in(bus),
        .d_out(y_val)
    );

    reg32 ZHIGH (
        .clk(clk),
        .reset(reset),
        .en(zhigh_in),
        .d_in(bus),
        .d_out(zhigh_val)
    );

    reg32 ZLOW (
        .clk(clk),
        .reset(reset),
        .en(zlow_in),
        .d_in(bus),
        .d_out(zlow_val)
    );
    
    reg32 MAR (
        .clk(clk),
        .reset(reset),
        .en(mar_in),
        .d_in(bus),
        .d_out(mar_val)
    );

    reg32 HI (
        .clk(clk),
        .reset(reset),
        .en(hi_in),
        .d_in(bus),
        .d_out(hi_val)
    );

    reg32 LO (
        .clk(clk),
        .reset(reset),
        .en(lo_in),
        .d_in(bus),
        .d_out(lo_val)
    );


endmodule