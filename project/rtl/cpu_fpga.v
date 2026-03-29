`timescale 1ns/10ps

module cpu_fpga (
    input  wire       CLOCK_50,
    input  wire [1:0] KEY,
    input  wire [9:0] SW,
    output wire [9:0] LEDR,
    output wire [6:0] HEX0,
    output wire [6:0] HEX1,
    output wire [6:0] HEX2,
    output wire [6:0] HEX3,
    output wire [6:0] HEX4,
    output wire [6:0] HEX5
);

    // Use SW[9:8] to choose a practical board clock without recompiling.
    // 00 -> ~1.56 MHz, 01 -> ~390 kHz, 10 -> ~97.6 kHz, 11 -> ~24.4 kHz
    localparam CLK_DIV_BITS = 11;

    reg [CLK_DIV_BITS:0] clk_div_cnt = { (CLK_DIV_BITS + 1) {1'b0} };
    wire [1:0] speed_sel = SW[9:8];
    wire       cpu_clk =
        (speed_sel == 2'b00) ? clk_div_cnt[4]  :
        (speed_sel == 2'b01) ? clk_div_cnt[6]  :
        (speed_sel == 2'b10) ? clk_div_cnt[8]  :
                               clk_div_cnt[10];

    always @(posedge CLOCK_50)
        clk_div_cnt <= clk_div_cnt + 1'b1;

    reg [1:0] key_sync_0 = 2'b0;
    reg [1:0] key_sync_1 = 2'b0;
    always @(posedge cpu_clk) begin
        key_sync_0 <= ~KEY;
        key_sync_1 <= key_sync_0;
    end

    wire reset_in = key_sync_1[0];
    wire stop_in  = key_sync_1[1];
    wire [31:0] device_in = {24'b0, SW[7:0]};

    wire [31:0] outport_val;
    wire        run;

    cpu #(
        .MEM_INIT_FILE("simulation/P4/memory_p4.hex")
    ) cpu_inst (
        .clk        (cpu_clk),
        .reset      (reset_in),
        .stop       (stop_in),
        .device_in  (device_in),
        .outport_val(outport_val),
        .run        (run)
    );

    seven_seg seg0 (
        .data   (outport_val[3:0]),
        .outputt(HEX0)
    );

    seven_seg seg1 (
        .data   (outport_val[7:4]),
        .outputt(HEX1)
    );

    assign HEX2 = 7'h7F;
    assign HEX3 = 7'h7F;
    assign HEX4 = 7'h7F;
    assign HEX5 = 7'h7F;

    assign LEDR[5]   = run;
    assign LEDR[4:0] = 5'b0;
    assign LEDR[9:6] = 4'b0;

endmodule
