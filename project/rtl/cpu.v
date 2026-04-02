`timescale 1ns/10ps
 
module cpu #(
    parameter MEM_INIT_FILE = "simulation/P3/memory_p3.hex"
) (
    input  wire        clk,
    input  wire        reset,
    input  wire        stop,
    input  wire [31:0] device_in,
    output wire [31:0] outport_val,
    output wire        run
);
 
    wire [4:0]  bus_sel;
    wire        pc_in, IncPC, ir_in, y_in, mar_in;
    wire        hi_in, lo_in;
    wire        MDRin, Read, ram_in;
    wire [4:0]  alu_op;
    wire        Zin;
    wire        Gra, Grb, Grc;
    wire        Rin, Rout, BAout, Cout;
    wire        con_en;
    wire        inport_in, outport_in;
    wire        jal_r12_in;
 
    wire [31:0] ir_val;
    wire        con;
 
    wire [31:0] BusMuxOut, pc_val, y_val, mar_val;
    wire [31:0] zhigh_out, zlow_out, Mdataout;
 
    control_unit cu (
        .clk        (clk),
        .reset      (reset),
        .stop       (stop),
        .con        (con),
        .IR         (ir_val),
        .MDR        (Mdataout),
 
        .bus_sel    (bus_sel),
        .pc_in      (pc_in),
        .IncPC      (IncPC),
        .ir_in      (ir_in),
        .y_in       (y_in),
        .mar_in     (mar_in),
        .hi_in      (hi_in),
        .lo_in      (lo_in),
        .MDRin      (MDRin),
        .Read       (Read),
        .ram_in     (ram_in),
        .alu_op     (alu_op),
        .Zin        (Zin),
        .Gra        (Gra),  .Grb       (Grb),  .Grc       (Grc),
        .Rin        (Rin),  .Rout      (Rout),
        .BAout      (BAout),.Cout      (Cout),
        .con_en     (con_en),
        .inport_in  (inport_in),
        .outport_in (outport_in),
        .jal_r12_in (jal_r12_in),
        .run        (run)
    );
 
    datapath_top #(
        .MEM_INIT_FILE(MEM_INIT_FILE)
    ) dp (
        .clk        (clk),
        .reset      (reset),
        .bus_sel    (bus_sel),
        .pc_in      (pc_in),
        .IncPC      (IncPC),
        .ir_in      (ir_in),
        .y_in       (y_in),
        .mar_in     (mar_in),
        .hi_in      (hi_in),
        .lo_in      (lo_in),
        .MDRin      (MDRin),
        .Read       (Read),
        .alu_op     (alu_op),
        .Zin        (Zin),
        .c_val      (32'b0),
        .ram_in     (ram_in),
        .device_in  (device_in),
        .inport_in  (inport_in),
        .outport_in (outport_in),
        .Gra        (Gra),  .Grb       (Grb),  .Grc       (Grc),
        .Rin        (Rin),  .Rout      (Rout),
        .BAout      (BAout),.Cout      (Cout),
        .con_en     (con_en),
        .jal_r12_in (jal_r12_in),
        .BusMuxOut  (BusMuxOut),
        .pc_val     (pc_val),
        .ir_val     (ir_val),
        .y_val      (y_val),
        .mar_val    (mar_val),
        .zhigh_out  (zhigh_out),
        .zlow_out   (zlow_out),
        .Mdataout   (Mdataout),
        .outport_val(outport_val),
        .con        (con)
    );
 
endmodule
