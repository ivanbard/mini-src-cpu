// =============================================================
//  cpu_fpga.v  —  Mini SRC Phase 4 DE0-CV top-level
//
//  Pin assignments (Cyclone V 5CEBA4F23C7):
//
//  Clock
//    CLOCK_50   PIN_M9       50 MHz board oscillator
//
//  Push-buttons (active-low on DE0-CV)
//    KEY[0]     PIN_U7       Reset (active-low  → reset = ~KEY[0])
//    KEY[1]     PIN_W9       Stop  (active-low  → stop  = ~KEY[1])
//
//  Slide switches  (SW[0]=lsb … SW[7]=msb of In.Port lower byte)
//    SW[0]      PIN_U13
//    SW[1]      PIN_V13
//    SW[2]      PIN_T13
//    SW[3]      PIN_T12
//    SW[4]      PIN_AA15
//    SW[5]      PIN_AB15
//    SW[6]      PIN_AA14
//    SW[7]      PIN_AA13
//
//  LEDs
//    LEDR[5]    PIN_N1       Run indicator (1 = running)
//
//  7-segment displays  (active-low segments)
//    HEX0[7:0]  Out.Port[3:0]  lower nibble  (digit 0, rightmost)
//    HEX1[7:0]  Out.Port[7:4]  upper nibble  (digit 1)
//    DE0-CV HEX0 pins: PIN_U21 PIN_V21 PIN_W22 PIN_W21 PIN_Y22 PIN_Y21 PIN_AA22 PIN_AA21
//    DE0-CV HEX1 pins: PIN_AA20 PIN_AB20 PIN_AA19 PIN_AA18 PIN_AB18 PIN_AA17 PIN_U22 PIN_Y20
//    (see DE0-CV user manual Table 3.5)
// =============================================================
`timescale 1ns/10ps

module cpu_fpga (
    // ---- board clock ----
    input  wire        CLOCK_50,

    // ---- push-buttons (active-low) ----
    input  wire [1:0]  KEY,

    // ---- slide switches ----
    input  wire [9:0]  SW,

    // ---- LEDs ----
    output wire [9:0]  LEDR,

    // ---- 7-segment displays ----
    output wire [7:0]  HEX0,
    output wire [7:0]  HEX1,
    output wire [7:0]  HEX2,   // unused — drive all segments off
    output wire [7:0]  HEX3,
    output wire [7:0]  HEX4,
    output wire [7:0]  HEX5
);

    // ----------------------------------------------------------
    // Clock divider
    // DE0-CV runs at 50 MHz; divide to ~1 MHz for reliable
    // simulation-equivalent behaviour in hardware.
    // Change CLK_DIV_BITS to tune: output freq = 50 MHz / 2^(N+1)
    //   N=4  → ~1.5 MHz
    //   N=5  → ~781 kHz
    //   N=9  → ~48 kHz  (good starting point)
    //   N=24 → ~1.5 Hz  (very slow, good for step-by-step debug)
    // ----------------------------------------------------------
    localparam CLK_DIV_BITS = 9;

    reg [CLK_DIV_BITS:0] clk_div_cnt;
    wire                 cpu_clk = clk_div_cnt[CLK_DIV_BITS];

    always @(posedge CLOCK_50)
        clk_div_cnt <= clk_div_cnt + 1'b1;

    // ----------------------------------------------------------
    // Active-low button debounce (simple synchroniser)
    // ----------------------------------------------------------
    reg [1:0] key_sync_0, key_sync_1;
    always @(posedge cpu_clk) begin
        key_sync_0 <= ~KEY;           // invert: 1 = pressed
        key_sync_1 <= key_sync_0;
    end
    wire reset_in = key_sync_1[0];   // KEY[0] pressed → reset
    wire stop_in  = key_sync_1[1];   // KEY[1] pressed → stop

    // ----------------------------------------------------------
    // In.Port: SW[7:0] → bits [7:0], upper bits = 0
    // ----------------------------------------------------------
    wire [31:0] device_in = {24'b0, SW[7:0]};

    // ----------------------------------------------------------
    // CPU instance
    // ----------------------------------------------------------
    wire [31:0] outport_val;
    wire        run;

    cpu cpu_inst (
        .clk        (cpu_clk),
        .reset      (reset_in),
        .stop       (stop_in),
        .device_in  (device_in),
        .outport_val(outport_val),
        .run        (run)
    );

    // ----------------------------------------------------------
    // 7-segment display: Out.Port[7:0] → HEX1 (upper nibble)
    //                                    HEX0 (lower nibble)
    // ----------------------------------------------------------
    seven_seg seg0 (
        .data   (outport_val[3:0]),
        .outputt(HEX0)
    );

    seven_seg seg1 (
        .data   (outport_val[7:4]),
        .outputt(HEX1)
    );

    // Unused displays: all segments off (active-low → all 1s)
    assign HEX2 = 8'hFF;
    assign HEX3 = 8'hFF;
    assign HEX4 = 8'hFF;
    assign HEX5 = 8'hFF;

    // ----------------------------------------------------------
    // Run LED: LEDR[5] = run signal
    // ----------------------------------------------------------
    assign LEDR[5]   = run;
    assign LEDR[4:0] = 5'b0;
    assign LEDR[9:6] = 4'b0;

endmodule