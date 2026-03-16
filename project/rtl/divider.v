// non-restoring divider
// +/- allowed for division per spec

module divider(
    input wire signed [31:0] Dividend,
    input wire signed [31:0] Divisor,
    output wire signed [31:0] Quotient,
    output wire signed [31:0] Remainder
);

    wire dividend_sign = Dividend[31];
    wire divisor_sign = Divisor[31];
    wire quotient_sign = dividend_sign ^ divisor_sign;
    wire remainder_sign = dividend_sign;
    
    wire [31:0] dividend_abs = dividend_sign ? (~Dividend + 1) : Dividend;
    wire [31:0] divisor_abs = divisor_sign ? (~Divisor + 1) : Divisor;
    
    wire [31:0] quotient_abs;
    wire [31:0] remainder_abs;
    
    non_restoring_divider_unsigned div_core (
        .Dividend(dividend_abs),
        .Divisor(divisor_abs),
        .Quotient(quotient_abs),
        .Remainder(remainder_abs)
    );
    
    assign Quotient = quotient_sign ? (~quotient_abs + 1) : quotient_abs;
    assign Remainder = remainder_sign ? (~remainder_abs + 1) : remainder_abs;

endmodule

module non_restoring_divider_unsigned(
    input wire [31:0] Dividend,
    input wire [31:0] Divisor,
    output wire [31:0] Quotient,
    output reg [31:0] Remainder
);

    reg [63:0] AQ;  // A=remainder, Q=quotient
    reg [31:0] M;
    integer i;
    
    reg [31:0] quotient_reg;
    
    always @(*) begin
        if (Divisor == 32'b0) begin
            quotient_reg = 32'hFFFFFFFF;
            Remainder = Dividend;
        end else begin
            AQ = {32'b0, Dividend};
            M = Divisor;
            
            for (i = 0; i < 32; i = i + 1) begin
                AQ = AQ << 1;
                
                if (AQ[63]) begin
                    AQ[63:32] = AQ[63:32] + M;
                end else begin
                    AQ[63:32] = AQ[63:32] - M;
                end
                
                if (AQ[63]) begin
                    AQ[0] = 1'b0;
                end else begin
                    AQ[0] = 1'b1;
                end
            end
            
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
