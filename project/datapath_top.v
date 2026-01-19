module datapath_top(
    input wire clk,
    input wire reset,
    input wire [15:0] rin,
    input wire [4:0]  bus_sel,

    input wire [31:0] inport_val,
    input wire [31:0] c_val,

    output wire [31:0] BusMuxOut
);

    wire [31:0] r0_out, r1_out, r2_out, r3_out, r4_out, r5_out, r6_out, r7_out;
    wire [31:0] r8_out, r9_out, r10_out, r11_out, r12_out, r13_out, r14_out, r15_out;

    //key regs as 0 since theyre not implemented YET
    wire [31:0] hi_val    = 32'b0;
    wire [31:0] lo_val    = 32'b0;
    wire [31:0] zhigh_val = 32'b0;
    wire [31:0] zlow_val  = 32'b0;
    wire [31:0] pc_val    = 32'b0;
    wire [31:0] mdr_val   = 32'b0;

    regfile16 rf (
        .clk(clk),
        .reset(reset),
        .rin(rin),
        .bus(BusMuxOut),
        .r0_out(r0_out), .r1_out(r1_out), .r2_out(r2_out), .r3_out(r3_out),
        .r4_out(r4_out), .r5_out(r5_out), .r6_out(r6_out), .r7_out(r7_out),
        .r8_out(r8_out), .r9_out(r9_out), .r10_out(r10_out), .r11_out(r11_out),
        .r12_out(r12_out), .r13_out(r13_out), .r14_out(r14_out), .r15_out(r15_out)
    );

    bus_mux_enc bmux (
        .bus_sel(bus_sel),

        .r0(r0_out), .r1(r1_out), .r2(r2_out), .r3(r3_out),
        .r4(r4_out), .r5(r5_out), .r6(r6_out), .r7(r7_out),
        .r8(r8_out), .r9(r9_out), .r10(r10_out), .r11(r11_out),
        .r12(r12_out), .r13(r13_out), .r14(r14_out), .r15(r15_out),

        .hi_val(hi_val),
        .lo_val(lo_val),
        .zhigh_val(zhigh_val),
        .zlow_val(zlow_val),
        .pc_val(pc_val),
        .mdr_val(mdr_val),

        .inport_val(inport_val),
        .c_val(c_val),

        .BusMuxOut(BusMuxOut)
    );

endmodule