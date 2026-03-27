module datapath_top(
    input wire clk,
    input wire reset,
    input wire [4:0] bus_sel,
 
    // Key register control signals
    input wire pc_in,
    input wire IncPC, // PC increment signal
    input wire ir_in,
    input wire y_in,
    input wire mar_in,
    input wire hi_in,
    input wire lo_in,
 
    // MDR control signals
    input wire MDRin,
    input wire Read,
 
    // ALU control
    input wire [4:0] alu_op,    // ALU operation select
    input wire Zin,             // Z register load enable
 
    // Drives C_extended for the time being, replace in phase 3
    // Put in 19 bit inputs now, C extended will extend if necessary
    input wire [31:0] c_val,
 
    // RAM control
    input wire ram_in,
 
    // Input Output control
    input wire [31:0] device_in,
    input wire inport_in,
    input wire outport_in,
 
    // Select Encode control
    input wire Gra, Grb, Grc,
    input wire Rin, Rout, BAout,
    input wire Cout,
 
    // Enable for con_ff
    input wire con_en,
 
    // Phase 3: jal saves return address directly to R12
    input wire jal_r12_in,
 
    output wire [31:0] BusMuxOut,
    
    // Key register outputs
    output wire [31:0] pc_val,
    output wire [31:0] ir_val,
    output wire [31:0] y_val,
    output wire [31:0] mar_val,
    
    // Z register outputs (for debugging/monitoring)
    output wire [31:0] zhigh_out,
    output wire [31:0] zlow_out,
    
    // Mdr output (to memory)
    output wire [31:0] Mdataout,
 
    output wire [31:0] outport_val,
 
    // Control signal output for condition met
<<<<<<< HEAD
    output wire con
 
=======
    output wire con,

    // ALU overflow flag
    output wire Overflow

>>>>>>> bce2a3c2b135366f152ddc5797cb6cec577ffd42
);
 
    wire [31:0] r0_out, r1_out, r2_out, r3_out, r4_out, r5_out, r6_out, r7_out;
    wire [31:0] r8_out, r9_out, r10_out, r11_out, r12_out, r13_out, r14_out, r15_out;
 
    wire [31:0] hi_val, lo_val;
    wire [31:0] mdr_val;
    
    // 64-bit Z register
    reg [63:0] Z_reg;
    wire [31:0] zhigh_val, zlow_val;
    assign zhigh_val = Z_reg[63:32];
    assign zlow_val = Z_reg[31:0];
    assign zhigh_out = zhigh_val;
    assign zlow_out = zlow_val;
    
    wire [63:0] alu_result;
<<<<<<< HEAD
 
=======
    wire alu_overflow;
    reg overflow_reg;

    assign Overflow = overflow_reg;

>>>>>>> bce2a3c2b135366f152ddc5797cb6cec577ffd42
    wire [31:0] ram_val;
 
    wire [31:0] inport_val;
 
    // Wires for select encode
    wire [15:0] Rin_decoded;
    wire [15:0] Rout_decoded;
    wire BAout_R0;
 
    // Wires for c_extend module
    wire [31:0] c_raw = c_val;
    wire [31:0] c_extended;
 
    wire [4:0] sel_encoded;
 
    regfile16 rf (
        .clk(clk),
        .reset(reset),
        .rin(Rin_decoded | (jal_r12_in ? 16'h1000 : 16'h0)),
        .r0_zeroes(BAout_R0),
        .bus(BusMuxOut),
        .r0_out(r0_out), .r1_out(r1_out), .r2_out(r2_out), .r3_out(r3_out),
        .r4_out(r4_out), .r5_out(r5_out), .r6_out(r6_out), .r7_out(r7_out),
        .r8_out(r8_out), .r9_out(r9_out), .r10_out(r10_out), .r11_out(r11_out),
        .r12_out(r12_out), .r13_out(r13_out), .r14_out(r14_out), .r15_out(r15_out)
    );
 
    key_regs key_regs_inst (
        .clk(clk),
        .reset(reset),
        .BusMuxOut(BusMuxOut),
        .pc_in(pc_in),
        .IncPC(IncPC),
        .pc_val(pc_val),
        .ir_in(ir_in),
        .ir_val(ir_val),
        .y_in(y_in),
        .y_val(y_val),
        .zhigh_in(1'b0),
        .zhigh_val(),
        .zlow_in(1'b0),
        .zlow_val(),
        .mar_in(mar_in),
        .mar_val(mar_val),
        .hi_in(hi_in),
        .hi_val(hi_val),
        .lo_in(lo_in),
        .lo_val(lo_val)
    );
 
    mdr mdr_inst (
        .clk(clk),
        .reset(reset),
        .MDRin(MDRin),
        .Read(Read),
        .BusMuxOut(BusMuxOut),
        .Mdatain(ram_val),
        .MDR_val(mdr_val)
    );
 
    assign Mdataout = mdr_val;
 
    ram ram_inst (
        .clk(clk),
        .ram_read(Read),      
        .ram_en(ram_in),  
        .ram_addr(mar_val[8:0]), 
        .ram_in(BusMuxOut),
        .ram_val(ram_val) // goes into MDR
    );
 
    select_encode select_encode_inst (
        .IRin(ir_val),
        .Gra(Gra),
        .Grb(Grb),
        .Grc(Grc),
        .Rin(Rin),
        .Rout(Rout),
        .BAout(BAout),
        .Rin_decoded(Rin_decoded),
        .Rout_decoded(Rout_decoded),
        .BAout_R0(BAout_R0)
    );
 
    extend_c extend_c_inst (
        .IRin(ir_val),
        .Cout(Cout),
        .C_extended(c_extended)
    );
 
    // Choose appropriate c value based on c_extend
    wire [31:0] c_bus_val = Cout ? c_extended : c_raw;
 
    // Phase 2 input for bus_sel and select encode R0 to R15 bus output
    mux_encoder mux_encoder_inst (
        .Rout_decoded(Rout_decoded),
        .other_sel(bus_sel),
        .mux_sel(sel_encoded)
    );
 
    con_ff conff_inst (
        .clk(clk),
        .reset(reset),
        .con_en(con_en),
        .BusMuxOut(BusMuxOut),
        .c2(ir_val[20:19]),
        .con(con)
    );
 
    alu alu_inst (
        .A(y_val),
        .B(BusMuxOut),
        .op(alu_op),
        .C(alu_result),
        .Overflow(alu_overflow)
    );
 
    outport outport_inst (
        .clk(clk),
        .reset(reset),
        .outport_in(outport_in),
        .BusMuxOut(BusMuxOut), 
        .outport_val(outport_val)
    );
 
    inport inport_inst (
        .clk(clk),
        .reset(reset),
        .inport_in(inport_in),
        .device_in(device_in),
        .inport_val(inport_val)
    );
 
    // Z register loads ALU result
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            Z_reg <= 64'b0;
            overflow_reg <= 1'b0;
        end else if (Zin) begin
            Z_reg <= alu_result;
            overflow_reg <= alu_overflow;
        end
    end
 
    bus_mux_enc bmux (
        .bus_sel(sel_encoded),
 
        .r0(r0_out), .r1(r1_out), .r2(r2_out), .r3(r3_out),
        .r4(r4_out), .r5(r5_out), .r6(r6_out), .r7(r7_out),
        .r8(r8_out), .r9(r9_out), .r10(r10_out), .r11(r11_out),
        .r12(r12_out), .r13(r13_out), .r14(r14_out), .r15(r15_out),
 
        .hi_val(hi_val),
        .lo_val(lo_val),
        .zhigh_val(zhigh_val),
        .zlow_val(zlow_val),
        .pc_val(pc_val),
        .mdr_val(mdr_val),
 
        .inport_val(inport_val),
        .c_val(c_bus_val),
 
        .BusMuxOut(BusMuxOut)
    );
 
endmodule