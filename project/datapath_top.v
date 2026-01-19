module datapath_top(
    input wire clk,
    input wire reset,
    input wire [31:0] rin,
    input wire [31:0] rout,
    output wire [31:0] bus
);

    wire [31:0] r0_out, r1_out, r2_out, r3_out, r4_out, r5_out, r6_out, r7_out;
    wire [31:0] r8_out, r9_out, r10_out, r11_out, r12_out, r13_out, r14_out, r15_out;

    regfile16 rf (
        .clk(clk),
        .reset(reset),
        .rin(rin),
        .bus(bus),
        .r0_out(r0_out), .r1_out(r1_out), .r2_out(r2_out), .r3_out(r3_out),
        .r4_out(r4_out), .r5_out(r5_out), .r6_out(r6_out), .r7_out(r7_out),
        .r8_out(r8_out), .r9_out(r9_out), .r10_out(r10_out), .r11_out(r11_out),
        .r12_out(r12_out), .r13_out(r13_out), .r14_out(r14_out), .r15_out(r15_out)
    );

    bus_mux16 bmux (
        .rout(rout),
        .r0(r0_out), .r1(r1_out), .r2(r2_out), .r3(r3_out),
        .r4(r4_out), .r5(r5_out), .r6(r6_out), .r7(r7_out),
        .r8(r8_out), .r9(r9_out), .r10(r10_out), .r11(r11_out),
        .r12(r12_out), .r13(r13_out), .r14(r14_out), .r15(r15_out),
        .bus(bus)
    );

endmodule