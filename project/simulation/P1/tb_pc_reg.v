`timescale 1ns/10ps

// Testbench for PC with IncPC functionality
module tb_pc_reg;
    reg clk;
    reg reset;
    reg pc_in;
    reg IncPC;
    reg [31:0] BusMuxOut;
    wire [31:0] pc_val;

    // Instantiate PC register
    pc_reg uut (
        .clk(clk),
        .reset(reset),
        .pc_in(pc_in),
        .IncPC(IncPC),
        .BusMuxOut(BusMuxOut),
        .pc_val(pc_val)
    );

    // Clock generation: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        $dumpfile("pc_reg.vcd");
        $dumpvars(0, tb_pc_reg);
        
        // Initialize
        reset = 1;
        pc_in = 0;
        IncPC = 0;
        BusMuxOut = 32'h00000000;
        
        // Release reset
        #10 reset = 0;
        #10;
        
        $display("========================================");
        $display("PC Register with IncPC Testbench");
        $display("========================================\n");
        
        // Test 1: Load value from bus
        $display("Test 1: Load PC from bus");
        BusMuxOut = 32'h00001000;
        pc_in = 1;
        #10;
        pc_in = 0;
        #10;
        $display("  Loaded 0x1000, PC = 0x%h %s", pc_val, 
                 (pc_val == 32'h00001000) ? "PASS" : "FAIL");
        
        // Test 2: Increment PC
        $display("\nTest 2: Increment PC (3 times)");
        IncPC = 1;
        #10;  // PC should be 0x1001
        $display("  After 1st IncPC: PC = 0x%h %s", pc_val,
                 (pc_val == 32'h00001001) ? "PASS" : "FAIL");
        #10;  // PC should be 0x1002
        $display("  After 2nd IncPC: PC = 0x%h %s", pc_val,
                 (pc_val == 32'h00001002) ? "PASS" : "FAIL");
        #10;  // PC should be 0x1003
        $display("  After 3rd IncPC: PC = 0x%h %s", pc_val,
                 (pc_val == 32'h00001003) ? "PASS" : "FAIL");
        IncPC = 0;
        #10;
        
        // Test 3: Hold value when no signals asserted
        $display("\nTest 3: Hold value (no signals)");
        #20;
        $display("  PC should still be 0x1003: PC = 0x%h %s", pc_val,
                 (pc_val == 32'h00001003) ? "PASS" : "FAIL");
        
        // Test 4: Load overrides increment (pc_in has priority)
        $display("\nTest 4: Load has priority over IncPC");
        BusMuxOut = 32'h00002000;
        pc_in = 1;
        IncPC = 1;  // Both asserted, load should win
        #10;
        pc_in = 0;
        IncPC = 0;
        #10;
        $display("  Load 0x2000 with IncPC also set: PC = 0x%h %s", pc_val,
                 (pc_val == 32'h00002000) ? "PASS" : "FAIL");
        
        // Test 5: Reset clears PC
        $display("\nTest 5: Reset clears PC");
        reset = 1;
        #10;
        reset = 0;
        #10;
        $display("  After reset: PC = 0x%h %s", pc_val,
                 (pc_val == 32'h00000000) ? "PASS" : "FAIL");
        
        // Test 6: Increment from zero
        $display("\nTest 6: Increment from zero");
        IncPC = 1;
        #10;
        IncPC = 0;
        #10;
        $display("  0 + 1 = PC = 0x%h %s", pc_val,
                 (pc_val == 32'h00000001) ? "PASS" : "FAIL");
        
        $display("\n========================================");
        $display("PC Register Tests Complete");
        $display("========================================");
        
        #20;
        $finish;
    end

endmodule
