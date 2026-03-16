// 32-bit register
module reg32 (
    input wire clk,
    input wire reset,
    input wire en,
    input wire [31:0] d_in,
    output reg [31:0] d_out
);

    always @(posedge clk) begin
        if (reset)
            d_out <= 32'b0;
        else if (en)
            d_out <= d_in;
    end

endmodule

module regfile16(
    input wire clk,
    input wire reset,
    input wire [15:0] rin,
    input wire [31:0] bus,
    output wire [31:0] r0_out,
    output wire [31:0] r1_out,
    output wire [31:0] r2_out,
    output wire [31:0] r3_out,
    output wire [31:0] r4_out,
    output wire [31:0] r5_out,
    output wire [31:0] r6_out,
    output wire [31:0] r7_out,
    output wire [31:0] r8_out,
    output wire [31:0] r9_out,
    output wire [31:0] r10_out,
    output wire [31:0] r11_out,
    output wire [31:0] r12_out,
    output wire [31:0] r13_out,
    output wire [31:0] r14_out,
    output wire [31:0] r15_out
);

    reg32 r0 (
        .clk(clk),
        .reset(reset),
        .en(rin[0]),
        .d_in(bus),
        .d_out(r0_out)
    );

    reg32 r1 (
        .clk(clk),
        .reset(reset),
        .en(rin[1]),
        .d_in(bus),
        .d_out(r1_out)
    );
    reg32 r2 (
        .clk(clk),
        .reset(reset),
        .en(rin[2]),
        .d_in(bus),
        .d_out(r2_out)
    );
    reg32 r3 (
        .clk(clk),
        .reset(reset),
        .en(rin[3]),
        .d_in(bus),
        .d_out(r3_out)
    );
    reg32 r4 (
        .clk(clk),
        .reset(reset),
        .en(rin[4]),
        .d_in(bus),
        .d_out(r4_out)
    );
    reg32 r5 (
        .clk(clk),
        .reset(reset),
        .en(rin[5]),
        .d_in(bus),
        .d_out(r5_out)
    );
    reg32 r6 (
        .clk(clk),
        .reset(reset),
        .en(rin[6]),
        .d_in(bus),
        .d_out(r6_out)
    );
    reg32 r7 (
        .clk(clk),
        .reset(reset),
        .en(rin[7]),
        .d_in(bus),
        .d_out(r7_out)
    );
    reg32 r8 (
        .clk(clk),
        .reset(reset),
        .en(rin[8]),
        .d_in(bus),
        .d_out(r8_out)
    );
    reg32 r9 (
        .clk(clk),
        .reset(reset),
        .en(rin[9]),
        .d_in(bus),
        .d_out(r9_out)
    );
    reg32 r10 (
        .clk(clk),
        .reset(reset),
        .en(rin[10]),
        .d_in(bus),
        .d_out(r10_out)
    );
    reg32 r11 (
        .clk(clk),
        .reset(reset),
        .en(rin[11]),
        .d_in(bus),
        .d_out(r11_out)
    );
    reg32 r12 (
        .clk(clk),
        .reset(reset),
        .en(rin[12]),
        .d_in(bus),
        .d_out(r12_out)
    );
    reg32 r13 (
        .clk(clk),
        .reset(reset),
        .en(rin[13]),
        .d_in(bus),
        .d_out(r13_out)
    );
    reg32 r14 (
        .clk(clk),
        .reset(reset),
        .en(rin[14]),
        .d_in(bus),
        .d_out(r14_out)
    );
    reg32 r15 (
        .clk(clk),
        .reset(reset),
        .en(rin[15]),
        .d_in(bus),
        .d_out(r15_out)
    );

endmodule