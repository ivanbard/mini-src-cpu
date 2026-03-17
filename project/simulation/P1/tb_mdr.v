`timescale 1ns/10ps

// Testbench for MDR (Memory Data Register)
module tb_mdr;
    reg clk;
    reg reset;
    reg MDRin;
    reg Read;
    reg [31:0] BusMuxOut;
    reg [31:0] Mdatain;
    wire [31:0] MDR_val;

    // Instantiate MDR
    mdr mdr_inst (
        .clk(clk),
        .reset(reset),
        .MDRin(MDRin),
        .Read(Read),
        .BusMuxOut(BusMuxOut),
        .Mdatain(Mdatain),
        .MDR_val(MDR_val)
    );

    // Clock generation: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        $dumpfile("mdr.vcd");
        $dumpvars(0, tb_mdr);
        
        // Initialize signals
        reset = 1;
        MDRin = 0;
        Read = 0;
        BusMuxOut = 32'h00000000;
        Mdatain = 32'h00000000;
        
        // Release reset
        #10 reset = 0;
        
        // Test 1: Load from bus (Read=0)
        #10;
        BusMuxOut = 32'hDEADBEEF;
        Mdatain = 32'h12345678;
        MDRin = 1;
        Read = 0;  // Select bus input
        #10;
        MDRin = 0;
        #10;
        $display("Test 1 - Load from bus:");
        $display("  Expected: 0xDEADBEEF, Got: 0x%h %s", MDR_val, 
                 (MDR_val == 32'hDEADBEEF) ? "PASS" : "FAIL");
        
        // Test 2: Load from memory (Read=1)
        #10;
        BusMuxOut = 32'hAAAAAAAA;
        Mdatain = 32'h87654321;
        MDRin = 1;
        Read = 1;  // Select memory input
        #10;
        MDRin = 0;
        #10;
        $display("Test 2 - Load from memory:");
        $display("  Expected: 0x87654321, Got: 0x%h %s", MDR_val,
                 (MDR_val == 32'h87654321) ? "PASS" : "FAIL");
        
        // Test 3: No load when MDRin=0
        #10;
        BusMuxOut = 32'hFFFFFFFF;
        Mdatain = 32'h11111111;
        MDRin = 0;  // Should not load
        Read = 0;
        #10;
        $display("Test 3 - Hold value (MDRin=0):");
        $display("  Expected: 0x87654321, Got: 0x%h %s", MDR_val,
                 (MDR_val == 32'h87654321) ? "PASS" : "FAIL");
        
        // Test 4: Reset functionality
        #10;
        reset = 1;
        #10;
        reset = 0;
        #10;
        $display("Test 4 - Reset:");
        $display("  Expected: 0x00000000, Got: 0x%h %s", MDR_val,
                 (MDR_val == 32'h00000000) ? "PASS" : "FAIL");
        
        #20;
        $display("\nMDR Tests Complete");
        $finish;
    end

endmodule
