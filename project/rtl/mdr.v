// MDR - dual input (memory or bus), dual output
module mdr(
    input wire clk,
    input wire reset,
    input wire MDRin,
    input wire Read,  // 1=from memory, 0=from bus
    input wire [31:0] BusMuxOut,
    input wire [31:0] Mdatain,
    output reg [31:0] MDR_val
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            MDR_val <= 32'b0;
        end else if (MDRin) begin
            MDR_val <= Read ? Mdatain : BusMuxOut;
        end
    end

endmodule
