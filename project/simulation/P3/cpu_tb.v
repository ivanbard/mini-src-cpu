// =============================================================
//  cpu_tb.v  -  Phase 3 testbench
//  Expected final values (verified by manual trace):
//    R0=0x614  R1=0x0    R2=0x4    R3=0x19
//    R4=0x6800 R5=0x680  R6=0xAF   R7=0x7
//    R8=0x9    R9=0x15   R10=0xB2  R11=0x5
//    R12=0x29  R13=0x10  R14=0xAB  R15=0x0
//    HI=0x4    LO=0x3
//    mem[0x89]=0x6C   mem[0xA3]=0x8
// =============================================================
`timescale 1ns/10ps

module cpu_tb;

    reg         clk, reset, stop;
    reg  [31:0] device_in;
    wire [31:0] outport_val;
    wire        run;

    cpu DUT (
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

    initial begin clk = 0; forever #10 clk = ~clk; end

    integer cycle_count;
    initial begin
        cycle_count = 0;
        forever begin
            @(posedge clk);
            cycle_count = cycle_count + 1;
            if (cycle_count > 50000) begin
                $display("TIMEOUT after %0d cycles", cycle_count);
                $finish;
            end
        end
    end

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

    initial begin
        $dumpfile("cpu_tb.vcd");
        $dumpvars(0, cpu_tb);
        device_in = 32'h0;
        stop      = 1'b0;

        dump_memory("memory_before.hex");
        $display("Memory dumped to memory_before.hex");

        reset = 1;
        repeat(3) @(posedge clk);
        #1 reset = 0;
        @(negedge run);
        repeat(2) @(posedge clk);

        $display("=======================================================");
        $display("  Phase 3 Program Complete  (%0d cycles)", cycle_count);
        $display("=======================================================");
        $display("  PC  = 0x%08h", pc_val);
        $display("  IR  = 0x%08h", ir_val);
        $display("  MAR = 0x%08h", mar_val);
        $display("  MDR = 0x%08h", mdr_val);
        $display("-------------------------------------------------------");
        $display("  R0  = 0x%08h   (exp 0x00000614)", DUT.dp.rf.r0_out);
        $display("  R1  = 0x%08h   (exp 0x00000000)", DUT.dp.rf.r1_out);
        $display("  R2  = 0x%08h   (exp 0x00000004)", DUT.dp.rf.r2_out);
        $display("  R3  = 0x%08h   (exp 0x00000019)", DUT.dp.rf.r3_out);
        $display("  R4  = 0x%08h   (exp 0x00006800)", DUT.dp.rf.r4_out);
        $display("  R5  = 0x%08h   (exp 0x00000680)", DUT.dp.rf.r5_out);
        $display("  R6  = 0x%08h   (exp 0x000000AF)", DUT.dp.rf.r6_out);
        $display("  R7  = 0x%08h   (exp 0x00000007)", DUT.dp.rf.r7_out);
        $display("  R8  = 0x%08h   (exp 0x00000009)", DUT.dp.rf.r8_out);
        $display("  R9  = 0x%08h   (exp 0x00000015)", DUT.dp.rf.r9_out);
        $display("  R10 = 0x%08h   (exp 0x000000B2)", DUT.dp.rf.r10_out);
        $display("  R11 = 0x%08h   (exp 0x00000005)", DUT.dp.rf.r11_out);
        $display("  R12 = 0x%08h   (exp 0x00000029)", DUT.dp.rf.r12_out);
        $display("  R13 = 0x%08h   (exp 0x00000010)", DUT.dp.rf.r13_out);
        $display("  R14 = 0x%08h   (exp 0x000000AB)", DUT.dp.rf.r14_out);
        $display("  R15 = 0x%08h   (exp 0x00000000)", DUT.dp.rf.r15_out);
        $display("  HI  = 0x%08h   (exp 0x00000004)", hi_val);
        $display("  LO  = 0x%08h   (exp 0x00000003)", lo_val);
        $display("-------------------------------------------------------");
        $display("  mem[0x089] = 0x%08h   (exp 0x0000006C)", DUT.dp.ram_inst.mem[9'h089]);
        $display("  mem[0x0A3] = 0x%08h   (exp 0x00000008)", DUT.dp.ram_inst.mem[9'h0A3]);
        $display("=======================================================");

        begin : check
            reg pass;
            pass = 1;
            if (DUT.dp.rf.r0_out  !== 32'h00000614) begin $display("  FAIL R0");  pass=0; end
            if (DUT.dp.rf.r1_out  !== 32'h00000000) begin $display("  FAIL R1");  pass=0; end
            if (DUT.dp.rf.r2_out  !== 32'h00000004) begin $display("  FAIL R2");  pass=0; end
            if (DUT.dp.rf.r3_out  !== 32'h00000019) begin $display("  FAIL R3");  pass=0; end
            if (DUT.dp.rf.r4_out  !== 32'h00006800) begin $display("  FAIL R4");  pass=0; end
            if (DUT.dp.rf.r5_out  !== 32'h00000680) begin $display("  FAIL R5");  pass=0; end
            if (DUT.dp.rf.r6_out  !== 32'h000000AF) begin $display("  FAIL R6");  pass=0; end
            if (DUT.dp.rf.r7_out  !== 32'h00000007) begin $display("  FAIL R7");  pass=0; end
            if (DUT.dp.rf.r8_out  !== 32'h00000009) begin $display("  FAIL R8");  pass=0; end
            if (DUT.dp.rf.r9_out  !== 32'h00000015) begin $display("  FAIL R9");  pass=0; end
            if (DUT.dp.rf.r10_out !== 32'h000000B2) begin $display("  FAIL R10"); pass=0; end
            if (DUT.dp.rf.r11_out !== 32'h00000005) begin $display("  FAIL R11"); pass=0; end
            if (DUT.dp.rf.r12_out !== 32'h00000029) begin $display("  FAIL R12"); pass=0; end
            if (DUT.dp.rf.r13_out !== 32'h00000010) begin $display("  FAIL R13"); pass=0; end
            if (DUT.dp.rf.r14_out !== 32'h000000AB) begin $display("  FAIL R14"); pass=0; end
            if (DUT.dp.rf.r15_out !== 32'h00000000) begin $display("  FAIL R15"); pass=0; end
            if (hi_val !== 32'h00000004) begin $display("  FAIL HI"); pass=0; end
            if (lo_val !== 32'h00000003) begin $display("  FAIL LO"); pass=0; end
            if (DUT.dp.ram_inst.mem[9'h089] !== 32'h0000006C) begin $display("  FAIL mem[0x89]"); pass=0; end
            if (DUT.dp.ram_inst.mem[9'h0A3] !== 32'h00000008) begin $display("  FAIL mem[0xA3]"); pass=0; end
            if (pass) $display("  >>> ALL CHECKS PASSED <<<");
            else      $display("  >>> SOME CHECKS FAILED <<<");
        end

        dump_memory("memory_after.hex");
        $display("Memory dumped to memory_after.hex");
        #20; $finish;
    end

endmodule
