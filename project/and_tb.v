// and_tb.v - Testbench for AND instruction
// Instruction: and R2, R5, R6
// Tests logical AND circuitry following Phase 1 control sequence
`timescale 1ns/10ps

module and_tb;
    // Clock and reset
    reg clk;
    reg reset;
    
    // Register file control
    reg [15:0] rin;           // R0in-R15in encoded
    reg [4:0] bus_sel;        // Bus select (which register drives the bus)
    
    // Key register control signals
    reg pc_in, IncPC, ir_in, y_in, mar_in, hi_in, lo_in;
    
    // MDR control
    reg MDRin, Read;
    reg [31:0] Mdatain;
    
    // ALU control
    reg [4:0] alu_op;
    reg Zin;
    
    // Other inputs
    reg [31:0] inport_val;
    reg [31:0] c_val;
    
    // Outputs
    wire [31:0] BusMuxOut;
    wire [31:0] pc_val, ir_val, y_val, mar_val;
    wire [31:0] zhigh_out, zlow_out;
    wire [31:0] Mdataout;

    // Bus select encodings
    localparam SEL_R0 = 5'd0,  SEL_R1 = 5'd1,  SEL_R2 = 5'd2,  SEL_R3 = 5'd3;
    localparam SEL_R4 = 5'd4,  SEL_R5 = 5'd5,  SEL_R6 = 5'd6,  SEL_R7 = 5'd7;
    localparam SEL_R8 = 5'd8,  SEL_R9 = 5'd9,  SEL_R10 = 5'd10, SEL_R11 = 5'd11;
    localparam SEL_R12 = 5'd12, SEL_R13 = 5'd13, SEL_R14 = 5'd14, SEL_R15 = 5'd15;
    localparam SEL_HI = 5'd16, SEL_LO = 5'd17;
    localparam SEL_ZHIGH = 5'd18, SEL_ZLOW = 5'd19;
    localparam SEL_PC = 5'd20, SEL_MDR = 5'd21;
    localparam SEL_INPORT = 5'd22, SEL_C = 5'd23;

    // ALU operation encodings
    localparam ALU_ADD  = 5'b00000;
    localparam ALU_SUB  = 5'b00001;
    localparam ALU_MUL  = 5'b00010;
    localparam ALU_DIV  = 5'b00011;
    localparam ALU_AND  = 5'b00100;
    localparam ALU_OR   = 5'b00101;
    localparam ALU_NOT  = 5'b00110;
    localparam ALU_NEG  = 5'b00111;
    localparam ALU_SHR  = 5'b01000;
    localparam ALU_SHRA = 5'b01001;
    localparam ALU_SHL  = 5'b01010;
    localparam ALU_ROR  = 5'b01011;
    localparam ALU_ROL  = 5'b01100;

    // State machine states
    parameter 
        Default = 4'b0000, 
        Reg_load1a = 4'b0001, Reg_load1b = 4'b0010, 
        Reg_load2a = 4'b0011, Reg_load2b = 4'b0100, 
        Reg_load3a = 4'b0101, Reg_load3b = 4'b0110, 
        T0 = 4'b0111, T1 = 4'b1000, T2 = 4'b1001, 
        T3 = 4'b1010, T4 = 4'b1011, T5 = 4'b1100,
        Done = 4'b1101;
    
    reg [3:0] Present_state = Default;

    // Instantiate the datapath
    datapath_top DUT (
        .clk(clk),
        .reset(reset),
        .rin(rin),
        .bus_sel(bus_sel),
        .pc_in(pc_in),
        .IncPC(IncPC),
        .ir_in(ir_in),
        .y_in(y_in),
        .mar_in(mar_in),
        .hi_in(hi_in),
        .lo_in(lo_in),
        .MDRin(MDRin),
        .Read(Read),
        .Mdatain(Mdatain),
        .alu_op(alu_op),
        .Zin(Zin),
        .inport_val(inport_val),
        .c_val(c_val),
        .BusMuxOut(BusMuxOut),
        .pc_val(pc_val),
        .ir_val(ir_val),
        .y_val(y_val),
        .mar_val(mar_val),
        .zhigh_out(zhigh_out),
        .zlow_out(zlow_out),
        .Mdataout(Mdataout)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // State machine - advances on clock edge
    always @(posedge clk) begin
        case (Present_state)
            Default:    Present_state = Reg_load1a;
            Reg_load1a: Present_state = Reg_load1b;
            Reg_load1b: Present_state = Reg_load2a;
            Reg_load2a: Present_state = Reg_load2b;
            Reg_load2b: Present_state = Reg_load3a;
            Reg_load3a: Present_state = Reg_load3b;
            Reg_load3b: Present_state = T0;
            T0:         Present_state = T1;
            T1:         Present_state = T2;
            T2:         Present_state = T3;
            T3:         Present_state = T4;
            T4:         Present_state = T5;
            T5:         Present_state = Done;
            Done:       Present_state = Done;
        endcase
    end

    // Control signals for each state
    always @(Present_state) begin
        case (Present_state)
            Default: begin
                // Initialize all signals
                rin <= 16'b0; bus_sel <= 5'b0;
                pc_in <= 0; IncPC <= 0; ir_in <= 0; y_in <= 0;
                mar_in <= 0; hi_in <= 0; lo_in <= 0;
                MDRin <= 0; Read <= 0; Mdatain <= 32'h00000000;
                alu_op <= 5'b0; Zin <= 0;
                inport_val <= 32'b0; c_val <= 32'b0;
            end
            
            // ===== Register Pre-loading Phase =====
            // Load R5 with 0x34
            Reg_load1a: begin
                Mdatain <= 32'h00000034;
                Read <= 1; MDRin <= 1;
            end
            Reg_load1b: begin
                Read <= 0; MDRin <= 0;
                bus_sel <= SEL_MDR;      // MDRout
                rin <= 16'b0000000000100000;  // R5in (bit 5)
            end
            
            // Load R6 with 0x45
            Reg_load2a: begin
                rin <= 16'b0;
                bus_sel <= 5'b0;
                Mdatain <= 32'h00000045;
                Read <= 1; MDRin <= 1;
            end
            Reg_load2b: begin
                Read <= 0; MDRin <= 0;
                bus_sel <= SEL_MDR;      // MDRout
                rin <= 16'b0000000001000000;  // R6in (bit 6)
            end
            
            // Load R2 with 0x67 (initial value, will be overwritten)
            Reg_load3a: begin
                rin <= 16'b0;
                bus_sel <= 5'b0;
                Mdatain <= 32'h00000067;
                Read <= 1; MDRin <= 1;
            end
            Reg_load3b: begin
                Read <= 0; MDRin <= 0;
                bus_sel <= SEL_MDR;      // MDRout
                rin <= 16'b0000000000000100;  // R2in (bit 2)
            end
            
            // ===== Instruction Execution Phase =====
            // T0: PCout, MARin, IncPC, Zin
            T0: begin
                rin <= 16'b0;
                bus_sel <= SEL_PC;       // PCout
                mar_in <= 1;             // MARin
                IncPC <= 1;              // IncPC
                alu_op <= ALU_ADD;       // Use ADD for PC+1 result in Z
                Zin <= 1;                // Zin
            end
            
            // T1: Zlowout, PCin, Read, Mdatain[31..0], MDRin
            T1: begin
                mar_in <= 0; IncPC <= 0; Zin <= 0;
                bus_sel <= SEL_ZLOW;     // Zlowout
                pc_in <= 1;              // PCin
                Read <= 1;               // Read
                MDRin <= 1;              // MDRin
                Mdatain <= 32'h4A920000; // Opcode for "and R2, R5, R6"
                                         // Format: 01001 01010 01001 00010 00000000000
                                         // AND=01001, Ra=R2=00010, Rb=R5=00101, Rc=R6=00110
            end
            
            // T2: MDRout, IRin
            T2: begin
                pc_in <= 0; Read <= 0; MDRin <= 0;
                bus_sel <= SEL_MDR;      // MDRout
                ir_in <= 1;              // IRin
            end
            
            // T3: R5out, Yin
            T3: begin
                ir_in <= 0;
                bus_sel <= SEL_R5;       // R5out
                y_in <= 1;               // Yin
            end
            
            // T4: R6out, AND, Zin
            T4: begin
                y_in <= 0;
                bus_sel <= SEL_R6;       // R6out
                alu_op <= ALU_AND;       // AND operation
                Zin <= 1;                // Zin
            end
            
            // T5: Zlowout, R2in
            T5: begin
                Zin <= 0;
                bus_sel <= SEL_ZLOW;     // Zlowout
                rin <= 16'b0000000000000100;  // R2in (bit 2)
            end
            
            Done: begin
                rin <= 16'b0;
                bus_sel <= 5'b0;
            end
        endcase
    end

    // Simulation control and verification
    initial begin
        $dumpfile("and_tb.vcd");
        $dumpvars(0, and_tb);
        
        reset = 1;
        #25 reset = 0;
        
        // Wait for execution to complete
        wait(Present_state == Done);
        #40;
        
        // Display results
        $display("==============================================");
        $display("AND Instruction Test: and R2, R5, R6");
        $display("==============================================");
        $display("R5 (operand 1) = 0x%h (expected: 0x00000034)", DUT.r5_out);
        $display("R6 (operand 2) = 0x%h (expected: 0x00000045)", DUT.r6_out);
        $display("R2 (result)    = 0x%h (expected: 0x00000004)", DUT.r2_out);
        $display("Expected: 0x34 AND 0x45 = 0x04");
        $display("==============================================");
        
        if (DUT.r2_out == 32'h00000004)
            $display("TEST PASSED!");
        else
            $display("TEST FAILED!");
        
        $display("==============================================");
        
        #20;
        $finish;
    end

endmodule
