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

    initial begin clk = 0; forever #10 clk = ~clk; end

    // Cycle counter
    integer cycle_count;
    integer instr_count;
    initial begin
        cycle_count = 0;
        instr_count = 0;
        forever begin
            @(posedge clk);
            cycle_count = cycle_count + 1;
            if (cycle_count > 100000) begin
                $display("TIMEOUT after %0d cycles", cycle_count);
                $finish;
            end
        end
    end

    // Instruction relevant register and memory contents
    always @(posedge clk) begin
        if (!reset && DUT.cu.IncPC) begin
            $display("");
            $display("Instr #%0d  [cycle %0d]  Fetching PC=0x%08h  IR_prev=0x%08h",
                     instr_count, cycle_count,
                     DUT.dp.pc_val,      // PC just put on bus (addr of this instr)
                     DUT.dp.ir_val);     // IR from previous instruction
            $display("R0 =0x%08h  R1 =0x%08h  R2 =0x%08h  R3 =0x%08h",
                     DUT.dp.rf.r0_out,  DUT.dp.rf.r1_out,
                     DUT.dp.rf.r2_out,  DUT.dp.rf.r3_out);
            $display("R4 =0x%08h  R5 =0x%08h  R6 =0x%08h  R7 =0x%08h",
                     DUT.dp.rf.r4_out,  DUT.dp.rf.r5_out,
                     DUT.dp.rf.r6_out,  DUT.dp.rf.r7_out);
            $display("R8 =0x%08h  R9 =0x%08h  R10=0x%08h  R11=0x%08h",
                     DUT.dp.rf.r8_out,  DUT.dp.rf.r9_out,
                     DUT.dp.rf.r10_out, DUT.dp.rf.r11_out);
            $display("R12=0x%08h  R13=0x%08h  R14=0x%08h  R15=0x%08h",
                     DUT.dp.rf.r12_out, DUT.dp.rf.r13_out,
                     DUT.dp.rf.r14_out, DUT.dp.rf.r15_out);
            $display("HI =0x%08h  LO =0x%08h  MAR=0x%08h  ZL =0x%08h",
                     DUT.dp.key_regs_inst.HI.d_out,
                     DUT.dp.key_regs_inst.LO.d_out,
                     DUT.dp.mar_val,
                     DUT.dp.zlow_out);
            $display("mem[0x89]=0x%08h  mem[0xA3]=0x%08h",
                     DUT.dp.ram_inst.mem[9'h089],
                     DUT.dp.ram_inst.mem[9'h0A3]);
            instr_count = instr_count + 1;
        end
    end

    initial begin
        $dumpfile("cpu_tb.vcd");
        $dumpvars(0, cpu_tb);
        device_in = 32'h0;
        stop      = 1'b0;
        reset = 1;
        repeat(3) @(posedge clk);
        #1 reset = 0;

        // Wait for halt
        @(negedge run);
        repeat(2) @(posedge clk);

        $display("");
        $display("  Final Contents");
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
        $display("  HI  = 0x%08h   (exp 0x00000004)", DUT.dp.key_regs_inst.HI.d_out);
        $display("  LO  = 0x%08h   (exp 0x00000003)", DUT.dp.key_regs_inst.LO.d_out);
        $display("  mem[0x089] = 0x%08h   (exp 0x0000006C)", DUT.dp.ram_inst.mem[9'h089]);
        $display("  mem[0x0A3] = 0x%08h   (exp 0x00000008)", DUT.dp.ram_inst.mem[9'h0A3]);

        // Memory dump to file
        begin : dump_mem
            integer fd, i;
            fd = $fopen("memory_out.hex", "w");
            for (i = 0; i < 512; i = i + 1)
                $fdisplay(fd, "%08X", DUT.dp.ram_inst.mem[i]);
            $fclose(fd);
            $display("Memory dumped to memory_out.hex");
        end

        #20; $finish;
    end

endmodule