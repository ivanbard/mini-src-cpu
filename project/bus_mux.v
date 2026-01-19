module bus_mux (
    input wire [15:0] rout,
    input wire pc_out_en,
    input wire hi_out_en,
    input wire lo_out_en,
    input wire z_hi_out_en,
    input wire z_lo_out_en,
    input wire mdr_out_en,
    input wire inport_out_en,
    input wire c_out_en,

    input wire [31:0] r0, input wire [31:0] r1, input wire [31:0] r2, input wire [31:0] r3,
    input wire [31:0] r4, input wire [31:0] r5, input wire [31:0] r6, input wire [31:0] r7,
    input wire [31:0] r8, input wire [31:0] r9, input wire [31:0] r10, input wire [31:0] r11,
    input wire [31:0] r12, input wire [31:0] r13, input wire [31:0] r14, input wire [31:0] r15,

    input wire [31:0] pc_val,
    input wire [31:0] hi_val,
    input wire [31:0] lo_val,
    input wire [31:0] z_hi_val,
    input wire [31:0] z_lo_val,
    input wire [31:0] mdr_val,
    input wire [31:0] inport_val,
    input wire [31:0] c_val,

    output wire [31:0] bus
);

    assign bus =
        rout[0]  ? r0  :
        rout[1]  ? r1  :
        rout[2]  ? r2  :
        rout[3]  ? r3  :
        rout[4]  ? r4  :
        rout[5]  ? r5  :
        rout[6]  ? r6  :
        rout[7]  ? r7  :
        rout[8]  ? r8  :
        rout[9]  ? r9  :
        rout[10] ? r10 :
        rout[11] ? r11 :
        rout[12] ? r12 :
        rout[13] ? r13 :
        rout[14] ? r14 :
        rout[15] ? r15 :
        pc_out_en     ? pc_val     :
        hi_out_en     ? hi_val     :
        lo_out_en     ? lo_val     :
        z_hi_out_en   ? z_hi_val   :
        z_lo_out_en   ? z_lo_val   :
        mdr_out_en    ? mdr_val    :
        inport_out_en ? inport_val :
        c_out_en      ? c_val      :
        32'b0;

endmodule