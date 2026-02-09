// 32x32 Booth multiplier with bit-pair recoding (radix-4)
// + operator allowed for mul circuitry per spec

module booth_multiplier(
    input wire signed [31:0] A,
    input wire signed [31:0] B,
    output wire signed [63:0] Product
);

    // bit-pair recoding: 16 iterations instead of 32
    // look at 3 bits at a time: B[2i+1:2i-1]
    
    wire [32:0] B_ext;
    assign B_ext = {B, 1'b0};  // append 0 for initial bit
    
    wire signed [63:0] pp [16:0];  // 17 partial products
    
    // booth encoding:
    // 000, 111 -> 0
    // 001, 010 -> +M
    // 011      -> +2M
    // 100      -> -2M
    // 101, 110 -> -M
    
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : booth_pp_gen
            wire [2:0] booth_bits;
            assign booth_bits = B_ext[2*i + 2 : 2*i];
            
            booth_partial_product bpp (
                .M(A),
                .booth_bits(booth_bits),
                .shift_amount(2 * i),
                .pp(pp[i])
            );
        end
    endgenerate
    
    // last partial product needs sign extension
    wire [2:0] last_booth_bits;
    assign last_booth_bits = {B[31], B[31], B_ext[31]};
    
    booth_partial_product bpp_last (
        .M(A),
        .booth_bits(last_booth_bits),
        .shift_amount(32),
        .pp(pp[16])
    );
    
    // wallace tree - add partial products in levels
    wire signed [63:0] sum_level1 [8:0];
    wire signed [63:0] sum_level2 [4:0];
    wire signed [63:0] sum_level3 [2:0];
    wire signed [63:0] sum_level4 [1:0];
    assign sum_level1[0] = pp[0] + pp[1];
    assign sum_level1[1] = pp[2] + pp[3];
    assign sum_level1[2] = pp[4] + pp[5];
    assign sum_level1[3] = pp[6] + pp[7];
    assign sum_level1[4] = pp[8] + pp[9];
    assign sum_level1[5] = pp[10] + pp[11];
    assign sum_level1[6] = pp[12] + pp[13];
    assign sum_level1[7] = pp[14] + pp[15];
    assign sum_level1[8] = pp[16];
    assign sum_level2[0] = sum_level1[0] + sum_level1[1];
    assign sum_level2[1] = sum_level1[2] + sum_level1[3];
    assign sum_level2[2] = sum_level1[4] + sum_level1[5];
    assign sum_level2[3] = sum_level1[6] + sum_level1[7];
    assign sum_level2[4] = sum_level1[8];
    assign sum_level3[0] = sum_level2[0] + sum_level2[1];
    assign sum_level3[1] = sum_level2[2] + sum_level2[3];
    assign sum_level3[2] = sum_level2[4];
    assign sum_level4[0] = sum_level3[0] + sum_level3[1];
    assign sum_level4[1] = sum_level3[2];
    
    assign Product = sum_level4[0] + sum_level4[1];

endmodule

module booth_partial_product(
    input wire signed [31:0] M,
    input wire [2:0] booth_bits,
    input wire [5:0] shift_amount,
    output wire signed [63:0] pp
);

    reg signed [63:0] pp_unshifted;
    
    wire signed [63:0] M_ext = {{32{M[31]}}, M};
    wire signed [63:0] M2 = M_ext <<< 1;
    
    always @(*) begin
        case (booth_bits)
            3'b000: pp_unshifted = 64'b0;
            3'b001: pp_unshifted = M_ext;
            3'b010: pp_unshifted = M_ext;
            3'b011: pp_unshifted = M2;
            3'b100: pp_unshifted = -M2;
            3'b101: pp_unshifted = -M_ext;
            3'b110: pp_unshifted = -M_ext;
            3'b111: pp_unshifted = 64'b0;
            default: pp_unshifted = 64'b0;
        endcase
    end
    
    assign pp = pp_unshifted <<< shift_amount;

endmodule
