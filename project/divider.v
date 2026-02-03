// Non-Restoring Divider - 32-bit
// Produces quotient and remainder for signed division
// Uses +/- operators as permitted by project requirements for division

module divider(
    input wire signed [31:0] Dividend,   // A (numerator)
    input wire signed [31:0] Divisor,    // B (denominator)
    output wire signed [31:0] Quotient,
    output wire signed [31:0] Remainder
);

    // Handle signs for signed division
    wire dividend_sign = Dividend[31];
    wire divisor_sign = Divisor[31];
    wire quotient_sign = dividend_sign ^ divisor_sign;
    wire remainder_sign = dividend_sign;
    
    // Get absolute values
    wire [31:0] dividend_abs = dividend_sign ? (~Dividend + 1) : Dividend;
    wire [31:0] divisor_abs = divisor_sign ? (~Divisor + 1) : Divisor;
    
    // Unsigned division using non-restoring algorithm
    wire [31:0] quotient_abs;
    wire [31:0] remainder_abs;
    
    non_restoring_divider_unsigned div_core (
        .Dividend(dividend_abs),
        .Divisor(divisor_abs),
        .Quotient(quotient_abs),
        .Remainder(remainder_abs)
    );
    
    // Apply signs to results
    // Quotient is negative if signs differ
    assign Quotient = quotient_sign ? (~quotient_abs + 1) : quotient_abs;
    // Remainder has same sign as dividend
    assign Remainder = remainder_sign ? (~remainder_abs + 1) : remainder_abs;

endmodule

// Non-Restoring Division - Unsigned 32-bit
module non_restoring_divider_unsigned(
    input wire [31:0] Dividend,
    input wire [31:0] Divisor,
    output wire [31:0] Quotient,
    output reg [31:0] Remainder
);

    reg [63:0] AQ;      // Combined A (remainder) and Q (quotient)
    reg [31:0] M;       // Divisor
    integer i;
    
    reg [31:0] quotient_reg;
    
    always @(*) begin
        // Handle divide by zero - return max values
        if (Divisor == 32'b0) begin
            quotient_reg = 32'hFFFFFFFF;
            Remainder = Dividend;
        end else begin
            // Initialize: A = 0, Q = Dividend, M = Divisor
            AQ = {32'b0, Dividend};
            M = Divisor;
            
            // Non-restoring division algorithm
            for (i = 0; i < 32; i = i + 1) begin
                // Shift AQ left by 1
                AQ = AQ << 1;
                
                // Check sign of A (upper 32 bits)
                if (AQ[63]) begin
                    // A is negative, add M
                    AQ[63:32] = AQ[63:32] + M;
                end else begin
                    // A is positive or zero, subtract M
                    AQ[63:32] = AQ[63:32] - M;
                end
                
                // Set quotient bit based on sign of result
                if (AQ[63]) begin
                    // A is negative, Q[0] = 0
                    AQ[0] = 1'b0;
                end else begin
                    // A is positive or zero, Q[0] = 1
                    AQ[0] = 1'b1;
                end
            end
            
            // Final correction: if A is negative, add M to get correct remainder
            if (AQ[63]) begin
                Remainder = AQ[63:32] + M;
            end else begin
                Remainder = AQ[63:32];
            end
            
            quotient_reg = AQ[31:0];
        end
    end
    
    assign Quotient = quotient_reg;

endmodule
