// div_tb.v - Testbench for DIV instruction (Section 3.6)
// Instruction: div R3, R1
// Note: Quotient goes to LO, Remainder goes to HI
`timescale 1ns/10ps

module div_tb;
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

    localparam SEL_R1 = 5'd1, SEL_R3 = 5'd3;
    localparam SEL_ZHIGH = 5'd18, SEL_ZLOW = 5'd19, SEL_PC = 5'd20, SEL_MDR = 5'd21;
    localparam ALU_ADD = 5'b00000, ALU_DIV = 5'b00011;

    parameter Default = 4'd0, Reg_load1a = 4'd1, Reg_load1b = 4'd2, 
              Reg_load2a = 4'd3, Reg_load2b = 4'd4,
              T0 = 4'd5, T1 = 4'd6, T2 = 4'd7, T3 = 4'd8, T4 = 4'd9, 
              T5 = 4'd10, T6 = 4'd11, Done = 4'd12;
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
            Reg_load2b: Present_state = T0;
            T0: Present_state = T1;
            T1: Present_state = T2;
            T2: Present_state = T3;
            T3: Present_state = T4;
            T4: Present_state = T5;
            T5: Present_state = T6;
            T6: Present_state = Done;
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
            // Load R3 with 17 (dividend)
            Reg_load1a: begin Mdatain <= 32'h00000011; Read <= 1; MDRin <= 1; end
            Reg_load1b: begin Read <= 0; MDRin <= 0; bus_sel <= SEL_MDR; rin <= 16'b0000000000001000; end  // R3in
            // Load R1 with 5 (divisor)
            Reg_load2a: begin rin <= 16'b0; bus_sel <= 5'b0; Mdatain <= 32'h00000005; Read <= 1; MDRin <= 1; end
            Reg_load2b: begin Read <= 0; MDRin <= 0; bus_sel <= SEL_MDR; rin <= 16'b0000000000000010; end  // R1in
            // T0: PCout, MARin, IncPC, Zin
            T0: begin rin <= 16'b0; bus_sel <= SEL_PC; mar_in <= 1; IncPC <= 1; alu_op <= ALU_ADD; Zin <= 1; end
            // T1: Zlowout, PCin, Read, Mdatain, MDRin
            T1: begin mar_in <= 0; IncPC <= 0; Zin <= 0; bus_sel <= SEL_ZLOW; pc_in <= 1; Read <= 1; MDRin <= 1; Mdatain <= 32'h78600000; end
            // T2: MDRout, IRin
            T2: begin pc_in <= 0; Read <= 0; MDRin <= 0; bus_sel <= SEL_MDR; ir_in <= 1; end
            // T3: R3out, Yin (dividend to Y)
            T3: begin ir_in <= 0; bus_sel <= SEL_R3; y_in <= 1; end
            // T4: R1out, DIV, Zin (divisor to ALU)
            T4: begin y_in <= 0; bus_sel <= SEL_R1; alu_op <= ALU_DIV; Zin <= 1; end
            // T5: Zlowout, LOin (quotient to LO)
            T5: begin Zin <= 0; bus_sel <= SEL_ZLOW; lo_in <= 1; end
            // T6: Zhighout, HIin (remainder to HI)
            T6: begin lo_in <= 0; bus_sel <= SEL_ZHIGH; hi_in <= 1; end
            Done: begin hi_in <= 0; bus_sel <= 5'b0; end
        endcase
    end

    initial begin
        $dumpfile("div_tb.vcd"); $dumpvars(0, div_tb);
        reset = 1; #25 reset = 0;
        wait(Present_state == Done); #40;
        $display("==============================================");
        $display("DIV Instruction Test: div R3, R1");
        $display("==============================================");
        $display("R3 (dividend)  = 0x%h (%0d)", DUT.r3_out, DUT.r3_out);
        $display("R1 (divisor)   = 0x%h (%0d)", DUT.r1_out, DUT.r1_out);
        $display("Z register     = 0x%h%h", zhigh_out, zlow_out);
        $display("LO (quotient)  = 0x%h (%0d) (expected: 3)", DUT.lo_val, DUT.lo_val);
        $display("HI (remainder) = 0x%h (%0d) (expected: 2)", DUT.hi_val, DUT.hi_val);
        $display("Expected: 17 / 5 = 3 remainder 2");
        if (DUT.lo_val == 32'h00000003 && DUT.hi_val == 32'h00000002) $display("TEST PASSED!");
        else $display("TEST FAILED!");
        $display("==============================================");
        #20; $finish;
    end
endmodule
