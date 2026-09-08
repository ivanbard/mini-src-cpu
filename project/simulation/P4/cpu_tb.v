// =============================================================
//  cpu_tb.v  -  Phase 4 testbench
//  Checks:
//    - official Phase 4 memory image is loaded
//    - In.Port reads 0xE0 from device input
//    - Out.Port sequence is:
//        E0 70 38 1C 0E 07 03 01   repeated 5 times
//        then final value 63
//    - CPU halts after the Phase 4 program completes
// =============================================================
`timescale 1ns/10ps

module cpu_tb;

    reg         clk, reset, stop;
    reg  [31:0] device_in;
    wire [31:0] outport_val;
    wire        run;

    cpu #(
        .MEM_INIT_FILE("simulation/P4/memory_p4.hex")
    ) DUT (
        .clk        (clk),
        .reset      (reset),
        .stop       (stop),
        .device_in  (device_in),
        .outport_val(outport_val),
        .run        (run)
    );

    wire [31:0] pc_val  = DUT.dp.pc_val;
    wire [31:0] ir_val  = DUT.dp.ir_val;
    wire [31:0] mar_val = DUT.dp.mar_val;
    wire [31:0] mdr_val = DUT.dp.Mdataout;
    wire [31:0] hi_val  = DUT.dp.key_regs_inst.HI.d_out;
    wire [31:0] lo_val  = DUT.dp.key_regs_inst.LO.d_out;

    integer cycle_count;
    integer exec_cycle_count;
    integer instr_count;
    integer out_count;
    integer delay_override;
    reg     pass;
    reg     dump_enabled;
    reg     quiet_mode;
    reg     using_delay_override;
    reg [31:0] expected_mem88;
    real    cpi;

    initial begin clk = 0; forever #10 clk = ~clk; end

    function [7:0] expected_out;
        input integer idx;
        begin
            if (idx < 40) begin
                case (idx % 8)
                    0: expected_out = 8'hE0;
                    1: expected_out = 8'h70;
                    2: expected_out = 8'h38;
                    3: expected_out = 8'h1C;
                    4: expected_out = 8'h0E;
                    5: expected_out = 8'h07;
                    6: expected_out = 8'h03;
                    default: expected_out = 8'h01;
                endcase
            end else if (idx == 40) begin
                expected_out = 8'h63;
            end else begin
                expected_out = 8'hXX;
            end
        end
    endfunction

    task dump_memory;
        input [8*32-1:0] filename;
        integer fd, i;
        begin
            fd = $fopen(filename, "w");
            for (i = 0; i < 512; i = i + 1)
                $fdisplay(fd, "%08X", DUT.dp.ram_inst.mem[i]);
            $fclose(fd);
        end
    endtask

    always @(posedge clk) begin
        cycle_count = cycle_count + 1;
        if (!reset && run)
            exec_cycle_count = exec_cycle_count + 1;
        if (!reset && DUT.cu.ir_in)
            instr_count = instr_count + 1;
        if (cycle_count > 80000000) begin
            $fatal(1, "TIMEOUT after %0d cycles", cycle_count);
        end

        if (DUT.cu.outport_in) begin
            if (!quiet_mode)
                $display("  OUT[%0d] = 0x%02h   (exp 0x%02h)", out_count, DUT.dp.BusMuxOut[7:0], expected_out(out_count));
            if (DUT.dp.BusMuxOut[7:0] !== expected_out(out_count)) begin
                $display("  FAIL OUT[%0d]", out_count);
                pass = 0;
            end
            out_count = out_count + 1;
        end
    end

    initial begin
        cycle_count = 0;
        exec_cycle_count = 0;
        instr_count = 0;
        out_count   = 0;
        delay_override = 0;
        pass        = 1'b1;
        dump_enabled = !$test$plusargs("nodump");
        quiet_mode = $test$plusargs("quiet");
        using_delay_override = 1'b0;
        expected_mem88 = 32'h0000FFFF;
        cpi = 0.0;
        device_in   = 32'h000000E0;
        stop        = 1'b0;

        if (dump_enabled) begin
            $dumpfile("cpu_tb_p4.vcd");
            $dumpvars(0, cpu_tb);
        end

        if (dump_enabled) begin
            dump_memory("memory_p4_before.hex");
            $display("Memory dumped to memory_p4_before.hex");
        end

        if ($value$plusargs("delay_hex=%h", delay_override)) begin
            using_delay_override = 1'b1;
            expected_mem88 = delay_override[31:0];
            DUT.dp.ram_inst.mem[9'h088] = delay_override[31:0];
            $display("Using delay override: mem[0x88] = 0x%08h", delay_override[31:0]);
        end

        reset = 1'b1;
        repeat(3) @(posedge clk);
        #1 reset = 1'b0;

        @(negedge run);
        repeat(2) @(posedge clk);
        if (instr_count != 0)
            cpi = (exec_cycle_count * 1.0) / instr_count;

        $display("=======================================================");
        $display("  Phase 4 Program Complete  (%0d cycles)", cycle_count);
        $display("=======================================================");
        $display("  PC  = 0x%08h", pc_val);
        $display("  IR  = 0x%08h", ir_val);
        $display("  MAR = 0x%08h", mar_val);
        $display("  MDR = 0x%08h", mdr_val);
        $display("-------------------------------------------------------");
        $display("  R0  = 0x%08h", DUT.dp.rf.r0_out);
        $display("  R1  = 0x%08h", DUT.dp.rf.r1_out);
        $display("  R2  = 0x%08h   (exp 0x00000000)", DUT.dp.rf.r2_out);
        $display("  R3  = 0x%08h   (exp 0x0000002E)", DUT.dp.rf.r3_out);
        $display("  R4  = 0x%08h", DUT.dp.rf.r4_out);
        $display("  R5  = 0x%08h   (exp 0x00000001)", DUT.dp.rf.r5_out);
        $display("  R6  = 0x%08h   (exp 0x00000063)", DUT.dp.rf.r6_out);
        $display("  R7  = 0x%08h   (exp 0x00000000)", DUT.dp.rf.r7_out);
        $display("  R8  = 0x%08h", DUT.dp.rf.r8_out);
        $display("  R9  = 0x%08h", DUT.dp.rf.r9_out);
        $display("  R10 = 0x%08h", DUT.dp.rf.r10_out);
        $display("  R11 = 0x%08h", DUT.dp.rf.r11_out);
        $display("  R12 = 0x%08h", DUT.dp.rf.r12_out);
        $display("  R13 = 0x%08h", DUT.dp.rf.r13_out);
        $display("  R14 = 0x%08h", DUT.dp.rf.r14_out);
        $display("  R15 = 0x%08h", DUT.dp.rf.r15_out);
        $display("  HI  = 0x%08h", hi_val);
        $display("  LO  = 0x%08h", lo_val);
        $display("-------------------------------------------------------");
        $display("  Out.Port = 0x%08h   (exp 0x00000063)", outport_val);
        $display("  mem[0x077] = 0x%08h   (exp 0x000000E0)", DUT.dp.ram_inst.mem[9'h077]);
        $display("  mem[0x088] = 0x%08h   (exp 0x%08h)", DUT.dp.ram_inst.mem[9'h088], expected_mem88);
        $display("  mem[0x089] = 0x%08h   (exp 0x0000006C)", DUT.dp.ram_inst.mem[9'h089]);
        $display("  mem[0x0A3] = 0x%08h   (exp 0x00000008)", DUT.dp.ram_inst.mem[9'h0A3]);
        $display("  out_count  = %0d       (exp 41)", out_count);
        $display("  fetched instructions = %0d", instr_count);
        $display("  execution cycles     = %0d", exec_cycle_count);
        $display("  CPI                  = %0.3f", cpi);
        $display("=======================================================");

        if (out_count !== 41) begin $display("  FAIL out_count"); pass = 0; end
        if (outport_val !== 32'h00000063) begin $display("  FAIL Out.Port"); pass = 0; end
        if (DUT.dp.rf.r2_out !== 32'h00000000) begin $display("  FAIL R2"); pass = 0; end
        if (DUT.dp.rf.r3_out !== 32'h0000002E) begin $display("  FAIL R3"); pass = 0; end
        if (DUT.dp.rf.r5_out !== 32'h00000001) begin $display("  FAIL R5"); pass = 0; end
        if (DUT.dp.rf.r6_out !== 32'h00000063) begin $display("  FAIL R6"); pass = 0; end
        if (DUT.dp.rf.r7_out !== 32'h00000000) begin $display("  FAIL R7"); pass = 0; end
        if (DUT.dp.ram_inst.mem[9'h077] !== 32'h000000E0) begin $display("  FAIL mem[0x77]"); pass = 0; end
        if (DUT.dp.ram_inst.mem[9'h088] !== expected_mem88) begin $display("  FAIL mem[0x88]"); pass = 0; end
        if (DUT.dp.ram_inst.mem[9'h089] !== 32'h0000006C) begin $display("  FAIL mem[0x89]"); pass = 0; end
        if (DUT.dp.ram_inst.mem[9'h0A3] !== 32'h00000008) begin $display("  FAIL mem[0xA3]"); pass = 0; end

        if (pass) $display("  >>> ALL CHECKS PASSED <<<");
        else      $fatal(1, "Phase 4 checks failed");

        if (dump_enabled) begin
            dump_memory("memory_p4_after.hex");
            $display("Memory dumped to memory_p4_after.hex");
        end
        #20 $finish;
    end

endmodule
