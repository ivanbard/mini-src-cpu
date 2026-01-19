module bus_mux_enc (
    input  wire [4:0]  bus_sel,

    input  wire [31:0] r0,  input wire [31:0] r1,  input wire [31:0] r2,  input wire [31:0] r3,
    input  wire [31:0] r4,  input wire [31:0] r5,  input wire [31:0] r6,  input wire [31:0] r7,
    input  wire [31:0] r8,  input wire [31:0] r9,  input wire [31:0] r10, input wire [31:0] r11,
    input  wire [31:0] r12, input wire [31:0] r13, input wire [31:0] r14, input wire [31:0] r15,

    input  wire [31:0] hi_val,
    input  wire [31:0] lo_val,
    input  wire [31:0] zhigh_val,
    input  wire [31:0] zlow_val,
    input  wire [31:0] pc_val,
    input  wire [31:0] mdr_val,
    input  wire [31:0] inport_val,
    input  wire [31:0] c_val,

    output reg  [31:0] BusMuxOut
);

    always @(*) begin
        case (bus_sel)
        5'd0:  BusMuxOut = r0;
        5'd1:  BusMuxOut = r1;
        5'd2:  BusMuxOut = r2;
        5'd3:  BusMuxOut = r3;
        5'd4:  BusMuxOut = r4;
        5'd5:  BusMuxOut = r5;
        5'd6:  BusMuxOut = r6;
        5'd7:  BusMuxOut = r7;
        5'd8:  BusMuxOut = r8;
        5'd9:  BusMuxOut = r9;
        5'd10:  BusMuxOut = r10;
        5'd11:  BusMuxOut = r11;
        5'd12:  BusMuxOut = r12;
        5'd13:  BusMuxOut = r13;
        5'd14:  BusMuxOut = r14;
        5'd15:  BusMuxOut = r15;

        5'd16: BusMuxOut = hi_val;
        5'd17: BusMuxOut = lo_val;
        5'd18: BusMuxOut = zhigh_val;
        5'd19: BusMuxOut = zlow_val;
        5'd20: BusMuxOut = pc_val;
        5'd21: BusMuxOut = mdr_val;
        5'd22: BusMuxOut = inport_val;
        5'd23: BusMuxOut = c_val;

        default: BusMuxOut = 32'b0;
        endcase
    end

endmodule
