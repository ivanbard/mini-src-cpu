// rol_tb.v - Testbench for ROL instruction (Section 3.11)
// Instruction: rol R7, R0, R4 (R7 = R0 rotated left by R4)
`timescale 1ns/10ps

module rol_tb;
    reg clk, reset;
    reg [15:0] rin;
    reg [4:0] bus_sel;
    reg pc_in, IncPC, ir_in, y_in, mar_in, hi_in, lo_in;
    reg MDRin, Read;
    reg [31:0] Mdatain;
    reg [4:0] alu_op;
    reg Zin;
    reg [31:0] inport_val, c_val;
    
    wire [31:0] BusMuxOut, pc_val, ir_val, y_val, mar_val;
    wire [31:0] zhigh_out, zlow_out, Mdataout;

    localparam SEL_R0 = 5'd0, SEL_R4 = 5'd4, SEL_R7 = 5'd7;
    localparam SEL_ZLOW = 5'd19, SEL_PC = 5'd20, SEL_MDR = 5'd21;
    localparam ALU_ADD = 5'b00000, ALU_ROL = 5'b01100;

    parameter Default = 4'd0, Reg_load1a = 4'd1, Reg_load1b = 4'd2, 
              Reg_load2a = 4'd3, Reg_load2b = 4'd4, Reg_load3a = 4'd5, Reg_load3b = 4'd6, 
              T0 = 4'd7, T1 = 4'd8, T2 = 4'd9, T3 = 4'd10, T4 = 4'd11, T5 = 4'd12, Done = 4'd13;
    reg [3:0] Present_state = Default;

    datapath_top DUT (
        .clk(clk), .reset(reset), .rin(rin), .bus_sel(bus_sel),
        .pc_in(pc_in), .IncPC(IncPC), .ir_in(ir_in), .y_in(y_in),
        .mar_in(mar_in), .hi_in(hi_in), .lo_in(lo_in),
        .MDRin(MDRin), .Read(Read), .Mdatain(Mdatain),
        .alu_op(alu_op), .Zin(Zin),
        .inport_val(inport_val), .c_val(c_val),
        .BusMuxOut(BusMuxOut), .pc_val(pc_val), .ir_val(ir_val),
        .y_val(y_val), .mar_val(mar_val),
        .zhigh_out(zhigh_out), .zlow_out(zlow_out), .Mdataout(Mdataout)
    );

    initial begin clk = 0; forever #10 clk = ~clk; end

    always @(posedge clk) begin
        case (Present_state)
            Default: Present_state = Reg_load1a;
            Reg_load1a: Present_state = Reg_load1b;
            Reg_load1b: Present_state = Reg_load2a;
            Reg_load2a: Present_state = Reg_load2b;
            Reg_load2b: Present_state = Reg_load3a;
            Reg_load3a: Present_state = Reg_load3b;
            Reg_load3b: Present_state = T0;
            T0: Present_state = T1;
            T1: Present_state = T2;
            T2: Present_state = T3;
            T3: Present_state = T4;
            T4: Present_state = T5;
            T5: Present_state = Done;
        endcase
    end

    always @(Present_state) begin
        case (Present_state)
            Default: begin
                rin <= 16'b0; bus_sel <= 5'b0;
                pc_in <= 0; IncPC <= 0; ir_in <= 0; y_in <= 0;
                mar_in <= 0; hi_in <= 0; lo_in <= 0;
                MDRin <= 0; Read <= 0; Mdatain <= 32'h0;
                alu_op <= 5'b0; Zin <= 0;
                inport_val <= 32'b0; c_val <= 32'b0;
            end
            // Load R0 with 0x80000000 (value to rotate)
            Reg_load1a: begin Mdatain <= 32'h80000000; Read <= 1; MDRin <= 1; end
            Reg_load1b: begin Read <= 0; MDRin <= 0; bus_sel <= SEL_MDR; rin <= 16'b0000000000000001; end  // R0in
            // Load R4 with 4 (rotate amount)
            Reg_load2a: begin rin <= 16'b0; bus_sel <= 5'b0; Mdatain <= 32'h00000004; Read <= 1; MDRin <= 1; end
            Reg_load2b: begin Read <= 0; MDRin <= 0; bus_sel <= SEL_MDR; rin <= 16'b0000000000010000; end  // R4in
            // Load R7 with 0
            Reg_load3a: begin rin <= 16'b0; bus_sel <= 5'b0; Mdatain <= 32'h00000000; Read <= 1; MDRin <= 1; end
            Reg_load3b: begin Read <= 0; MDRin <= 0; bus_sel <= SEL_MDR; rin <= 16'b0000000010000000; end  // R7in
            // T0: PCout, MARin, IncPC, Zin
            T0: begin rin <= 16'b0; bus_sel <= SEL_PC; mar_in <= 1; IncPC <= 1; alu_op <= ALU_ADD; Zin <= 1; end
            // T1: Zlowout, PCin, Read, Mdatain, MDRin
            T1: begin mar_in <= 0; IncPC <= 0; Zin <= 0; bus_sel <= SEL_ZLOW; pc_in <= 1; Read <= 1; MDRin <= 1; Mdatain <= 32'hC3808000; end
            // T2: MDRout, IRin
            T2: begin pc_in <= 0; Read <= 0; MDRin <= 0; bus_sel <= SEL_MDR; ir_in <= 1; end
            // T3: R0out, Yin
            T3: begin ir_in <= 0; bus_sel <= SEL_R0; y_in <= 1; end
            // T4: R4out, ROL, Zin
            T4: begin y_in <= 0; bus_sel <= SEL_R4; alu_op <= ALU_ROL; Zin <= 1; end
            // T5: Zlowout, R7in
            T5: begin Zin <= 0; bus_sel <= SEL_ZLOW; rin <= 16'b0000000010000000; end  // R7in
            Done: begin rin <= 16'b0; bus_sel <= 5'b0; end
        endcase
    end

    initial begin
        $dumpfile("rol_tb.vcd"); $dumpvars(0, rol_tb);
        reset = 1; #25 reset = 0;
        wait(Present_state == Done); #40;
        $display("==============================================");
        $display("ROL Instruction Test: rol R7, R0, R4");
        $display("==============================================");
        $display("R0 (value)      = 0x%h", DUT.r0_out);
        $display("R4 (rotate amt) = 0x%h (%0d)", DUT.r4_out, DUT.r4_out);
        $display("R7 (result)     = 0x%h (expected: 0x00000008)", DUT.r7_out);
        $display("Expected: 0x80000000 ROL 4 = 0x00000008");
        if (DUT.r7_out == 32'h00000008) $display("TEST PASSED!");
        else $display("TEST FAILED!");
        $display("==============================================");
        #20; $finish;
    end
endmodule
