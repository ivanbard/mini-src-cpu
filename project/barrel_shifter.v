// 5-stage barrel shifter

module barrel_shifter(
    input wire [31:0] A,
    input wire [4:0] B,  // shift amount
    output wire [31:0] shr_out,
    output wire [31:0] shra_out,
    output wire [31:0] shl_out,
    output wire [31:0] ror_out,
    output wire [31:0] rol_out
);

    // SHR - logical right shift
    wire [31:0] shr_stage0, shr_stage1, shr_stage2, shr_stage3, shr_stage4;
    
    assign shr_stage0 = B[0] ? {1'b0, A[31:1]} : A;
    assign shr_stage1 = B[1] ? {2'b0, shr_stage0[31:2]} : shr_stage0;
    assign shr_stage2 = B[2] ? {4'b0, shr_stage1[31:4]} : shr_stage1;
    assign shr_stage3 = B[3] ? {8'b0, shr_stage2[31:8]} : shr_stage2;
    assign shr_stage4 = B[4] ? {16'b0, shr_stage3[31:16]} : shr_stage3;
    assign shr_out = shr_stage4;

    // SHRA - arithmetic right shift (preserve sign)
    wire sign_bit = A[31];
    wire [31:0] shra_stage0, shra_stage1, shra_stage2, shra_stage3, shra_stage4;
    
    assign shra_stage0 = B[0] ? {sign_bit, A[31:1]} : A;
    assign shra_stage1 = B[1] ? {{2{sign_bit}}, shra_stage0[31:2]} : shra_stage0;
    assign shra_stage2 = B[2] ? {{4{sign_bit}}, shra_stage1[31:4]} : shra_stage1;
    assign shra_stage3 = B[3] ? {{8{sign_bit}}, shra_stage2[31:8]} : shra_stage2;
    assign shra_stage4 = B[4] ? {{16{sign_bit}}, shra_stage3[31:16]} : shra_stage3;
    assign shra_out = shra_stage4;

    // SHL - shift left
    wire [31:0] shl_stage0, shl_stage1, shl_stage2, shl_stage3, shl_stage4;
    
    assign shl_stage0 = B[0] ? {A[30:0], 1'b0} : A;
    assign shl_stage1 = B[1] ? {shl_stage0[29:0], 2'b0} : shl_stage0;
    assign shl_stage2 = B[2] ? {shl_stage1[27:0], 4'b0} : shl_stage1;
    assign shl_stage3 = B[3] ? {shl_stage2[23:0], 8'b0} : shl_stage2;
    assign shl_stage4 = B[4] ? {shl_stage3[15:0], 16'b0} : shl_stage3;
    assign shl_out = shl_stage4;

    // ROR - rotate right
    wire [31:0] ror_stage0, ror_stage1, ror_stage2, ror_stage3, ror_stage4;
    
    assign ror_stage0 = B[0] ? {A[0], A[31:1]} : A;
    assign ror_stage1 = B[1] ? {ror_stage0[1:0], ror_stage0[31:2]} : ror_stage0;
    assign ror_stage2 = B[2] ? {ror_stage1[3:0], ror_stage1[31:4]} : ror_stage1;
    assign ror_stage3 = B[3] ? {ror_stage2[7:0], ror_stage2[31:8]} : ror_stage2;
    assign ror_stage4 = B[4] ? {ror_stage3[15:0], ror_stage3[31:16]} : ror_stage3;
    assign ror_out = ror_stage4;

    // ROL - rotate left
    wire [31:0] rol_stage0, rol_stage1, rol_stage2, rol_stage3, rol_stage4;
    
    assign rol_stage0 = B[0] ? {A[30:0], A[31]} : A;
    assign rol_stage1 = B[1] ? {rol_stage0[29:0], rol_stage0[31:30]} : rol_stage0;
    assign rol_stage2 = B[2] ? {rol_stage1[27:0], rol_stage1[31:28]} : rol_stage1;
    assign rol_stage3 = B[3] ? {rol_stage2[23:0], rol_stage2[31:24]} : rol_stage2;
    assign rol_stage4 = B[4] ? {rol_stage3[15:0], rol_stage3[31:16]} : rol_stage3;
    assign rol_out = rol_stage4;

endmodule
