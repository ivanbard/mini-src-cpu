module datapath_top(
    input wire clk,
    input wire reset,
    input wire [15:0] rin,
    input wire [4:0]  bus_sel,

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
    input wire [31:0] Mdatain,  //Input from memory

    // ALU control
    input wire [4:0] alu_op,    // ALU operation select
    input wire Zin,             // Z register load enable

    input wire [31:0] inport_val,
    input wire [31:0] c_val,

    output wire [31:0] BusMuxOut,
    
    // Key register outputs
    output wire [31:0] pc_val,
    output wire [31:0] ir_val,
    output wire [31:0] y_val,
    output wire [31:0] mar_val,
    
    // Z register outputs (for debugging/monitoring)
    output wire [31:0] zhigh_out,
    output wire [31:0] zlow_out,
    
    // mdr output (to memory)
    output wire [31:0] Mdataout
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

    regfile16 rf (
        .clk(clk),
        .reset(reset),
        .rin(rin),
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
        .Mdatain(Mdatain),
        .MDR_val(mdr_val)
    );

    assign Mdataout = mdr_val;

    alu alu_inst (
        .A(y_val),
        .B(BusMuxOut),
        .op(alu_op),
        .C(alu_result)
    );

    // Z register loads ALU result
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            Z_reg <= 64'b0;
        end else if (Zin) begin
            Z_reg <= alu_result;
        end
    end

    bus_mux_enc bmux (
        .bus_sel(bus_sel),

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
        .c_val(c_val),

        .BusMuxOut(BusMuxOut)
    );

endmodule