// Booth Multiplier - 32x32 with Bit-Pair Recoding (Radix-4 Modified Booth)
// Produces 64-bit signed product
// Uses + operator as permitted by project requirements for multiplication

module booth_multiplier(
    input wire signed [31:0] A,    // Multiplicand
    input wire signed [31:0] B,    // Multiplier
    output wire signed [63:0] Product
);

    // Bit-pair recoding reduces iterations from 32 to 16
    // We examine 3 bits at a time: B[2i+1], B[2i], B[2i-1]
    // and generate partial products accordingly
    
    // Extended multiplier with extra bit for recoding
    wire [32:0] B_ext;
    assign B_ext = {B, 1'b0};  // B with implicit 0 at position -1
    
    // Partial products (17 partial products for 32-bit multiplier)
    wire signed [63:0] pp [16:0];
    
    // Booth recoding logic
    // For each pair of bits, we generate a partial product based on:
    // bits | action
    // 000  | +0
    // 001  | +M
    // 010  | +M
    // 011  | +2M
    // 100  | -2M
    // 101  | -M
    // 110  | -M
    // 111  | +0
    
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
    
    // Handle the last partial product (for bit 32)
    // Since we're doing signed multiplication, the last iteration needs special handling
    wire [2:0] last_booth_bits;
    assign last_booth_bits = {B[31], B[31], B_ext[31]};  // Sign extend for last iteration
    
    booth_partial_product bpp_last (
        .M(A),
        .booth_bits(last_booth_bits),
        .shift_amount(32),
        .pp(pp[16])
    );
    
    // Sum all partial products using Wallace tree or simple addition
    // Using + operator as permitted for multiplication circuitry
    wire signed [63:0] sum_level1 [8:0];
    wire signed [63:0] sum_level2 [4:0];
    wire signed [63:0] sum_level3 [2:0];
    wire signed [63:0] sum_level4 [1:0];
    
    // Level 1: Pair up 17 partial products
    assign sum_level1[0] = pp[0] + pp[1];
    assign sum_level1[1] = pp[2] + pp[3];
    assign sum_level1[2] = pp[4] + pp[5];
    assign sum_level1[3] = pp[6] + pp[7];
    assign sum_level1[4] = pp[8] + pp[9];
    assign sum_level1[5] = pp[10] + pp[11];
    assign sum_level1[6] = pp[12] + pp[13];
    assign sum_level1[7] = pp[14] + pp[15];
    assign sum_level1[8] = pp[16];  // Odd one out
    
    // Level 2
    assign sum_level2[0] = sum_level1[0] + sum_level1[1];
    assign sum_level2[1] = sum_level1[2] + sum_level1[3];
    assign sum_level2[2] = sum_level1[4] + sum_level1[5];
    assign sum_level2[3] = sum_level1[6] + sum_level1[7];
    assign sum_level2[4] = sum_level1[8];
    
    // Level 3
    assign sum_level3[0] = sum_level2[0] + sum_level2[1];
    assign sum_level3[1] = sum_level2[2] + sum_level2[3];
    assign sum_level3[2] = sum_level2[4];
    
    // Level 4
    assign sum_level4[0] = sum_level3[0] + sum_level3[1];
    assign sum_level4[1] = sum_level3[2];
    
    // Final result
    assign Product = sum_level4[0] + sum_level4[1];

endmodule

// Booth Partial Product Generator
module booth_partial_product(
    input wire signed [31:0] M,           // Multiplicand
    input wire [2:0] booth_bits,          // 3 bits for recoding
    input wire [5:0] shift_amount,        // How much to shift left
    output wire signed [63:0] pp          // Partial product
);

    reg signed [63:0] pp_unshifted;
    
    // Sign-extend multiplicand to 64 bits for operations
    wire signed [63:0] M_ext = {{32{M[31]}}, M};
    wire signed [63:0] M2 = M_ext <<< 1;  // 2M (arithmetic shift)
    
    always @(*) begin
        case (booth_bits)
            3'b000: pp_unshifted = 64'b0;           // +0
            3'b001: pp_unshifted = M_ext;           // +M
            3'b010: pp_unshifted = M_ext;           // +M
            3'b011: pp_unshifted = M2;              // +2M
            3'b100: pp_unshifted = -M2;             // -2M
            3'b101: pp_unshifted = -M_ext;          // -M
            3'b110: pp_unshifted = -M_ext;          // -M
            3'b111: pp_unshifted = 64'b0;           // +0
            default: pp_unshifted = 64'b0;
        endcase
    end
    
    // Shift left by the appropriate amount
    assign pp = pp_unshifted <<< shift_amount;

endmodule
