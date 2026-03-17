// ori R7, R4, 0x71  |  R4=0xF0  |  expect R7=0xF1
`timescale 1ns/10ps

module ori_tb;
    reg clk, reset;
    reg [4:0] bus_sel;
    reg pc_in, IncPC, ir_in, y_in, mar_in, hi_in, lo_in;
    reg MDRin, Read, Zin, inport_in, outport_in, con_en, ram_in;
    reg [4:0] alu_op;
    reg [31:0] c_val, device_in;
    reg Gra, Grb, Grc, Rin, Rout, BAout, Cout;

    wire [31:0] BusMuxOut, pc_val, ir_val, y_val, mar_val;
    wire [31:0] zhigh_out, zlow_out, Mdataout, outport_val;
    wire con;

    localparam SEL_HI=5'd16, SEL_LO=5'd17, SEL_ZLOW=5'd19,
               SEL_PC=5'd20, SEL_MDR=5'd21, SEL_INPORT=5'd22, SEL_C=5'd23;
    localparam OP_ADD=5'b00000, OP_AND=5'b00100, OP_OR=5'b00101;

    parameter Default=5'd0, RL0=5'd1, RL1=5'd2, RL2=5'd3, RL3=5'd4, RL4=5'd5,
              T0=5'd6, T1=5'd7, T2=5'd8, T3=5'd9, T4=5'd10, T5=5'd11, Done=5'd12;
    reg [4:0] Present_state = Default;

    datapath_top DUT(.clk(clk),.reset(reset),.bus_sel(bus_sel),
        .pc_in(pc_in),.IncPC(IncPC),.ir_in(ir_in),
        .y_in(y_in),.mar_in(mar_in),.hi_in(hi_in),.lo_in(lo_in),
        .MDRin(MDRin),.Read(Read),.alu_op(alu_op),.Zin(Zin),
        .c_val(c_val),.ram_in(ram_in),.device_in(device_in),
        .inport_in(inport_in),.outport_in(outport_in),.con_en(con_en),
        .Gra(Gra),.Grb(Grb),.Grc(Grc),
        .Rin(Rin),.Rout(Rout),.BAout(BAout),.Cout(Cout),
        .BusMuxOut(BusMuxOut),.pc_val(pc_val),.ir_val(ir_val),
        .y_val(y_val),.mar_val(mar_val),
        .zhigh_out(zhigh_out),.zlow_out(zlow_out),
        .Mdataout(Mdataout),.outport_val(outport_val),.con(con));

    initial begin clk=0; forever #10 clk=~clk; end

    always @(posedge clk) case(Present_state)
        Default: Present_state <= RL0;
        RL0:     Present_state <= RL1;
        RL1:     Present_state <= RL2;
        RL2:     Present_state <= RL3;
        RL3:     Present_state <= RL4;
        RL4:     Present_state <= T0;
        T0:      Present_state <= T1;
        T1:      Present_state <= T2;
        T2:      Present_state <= T3;
        T3: Present_state <= T4;
        T4: Present_state <= T5;
        T5: Present_state <= Done;
        default: Present_state <= Present_state;
    endcase

    task clear_sigs; begin
        bus_sel<=0; pc_in<=0; IncPC<=0; ir_in<=0; y_in<=0;
        mar_in<=0; hi_in<=0; lo_in<=0; MDRin<=0; Read<=0;
        alu_op<=0; Zin<=0; c_val<=0; ram_in<=0;
        inport_in<=0; outport_in<=0; con_en<=0;
        Gra<=0; Grb<=0; Grc<=0; Rin<=0; Rout<=0; BAout<=0; Cout<=0;
    end endtask

    always @(Present_state) begin
        clear_sigs;
        case(Present_state)
            RL0: begin c_val<=32'h00001FF; bus_sel<=SEL_C; mar_in<=1; end
            RL1: begin Read<=1; MDRin<=1; ram_in<=1; end
            RL2: begin bus_sel<=SEL_MDR; ir_in<=1; end
            RL3: ; // idle — IR.d_out settles to dummy (0x02000000)
            RL4: begin c_val<=32'h000000F0; bus_sel<=SEL_C; Gra<=1; Rin<=1; end
            T0: begin bus_sel<=SEL_PC; mar_in<=1; IncPC<=1; end
            T1: begin bus_sel<=SEL_ZLOW; Read<=1; MDRin<=1; ram_in<=1; end
            T2: begin bus_sel<=SEL_MDR; ir_in<=1; end
            T3: begin Grb<=1; Rout<=1; y_in<=1; end
            T4: begin Cout<=1; bus_sel<=SEL_C; alu_op<=OP_OR; Zin<=1; end
            T5: begin bus_sel<=SEL_ZLOW; Gra<=1; Rin<=1; end
        endcase
    end

    initial begin
        $dumpfile("ori_tb.vcd"); $dumpvars(0,ori_tb);
        DUT.ram_inst.mem[9'h1FF] = 32'h02000000;
        DUT.ram_inst.mem[9'h000] = 32'h3BA00071;
        reset=1; #25; reset=0;
        wait(Present_state==Done); #40;
        $display("============================================");
        $display("ORI: ori R7, R4, 0x71");
        $display("  R4  = 0x%08h  (exp 0x000000F0)", DUT.rf.r4_out);
        $display("  C_ext= 0x%08h  (exp 0x00000071)", DUT.extend_c_inst.C_extended);
        $display("  R7  = 0x%08h  (exp 0x000000F1)", DUT.rf.r7_out);
        if(DUT.rf.r7_out===32'h000000F1) $display("  >>> PASSED <<<");
        else $display("  >>> FAILED <<<");
        $display("============================================");
        #20; $finish;
    end
endmodule