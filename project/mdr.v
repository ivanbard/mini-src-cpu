// Memory Data Register 
// Dual input: from memory (Mdatain) or from bus (BusMuxOut)
// Dual output: to memory (Mdataout) and to bus
module mdr(
    input wire clk,
    input wire reset,
    input wire MDRin, //enable sig
    input wire Read, // select input: 1=from memory, 0=from bus
    input wire [31:0] BusMuxOut,  // input from internal bus
    input wire [31:0] Mdatain, // input from memory
    output reg [31:0] MDR_val  // output (goes to both bus and memory)
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            MDR_val <= 32'b0;
        end else if (MDRin) begin
            // if Read=1, load from memory, otherwise load from bus
            MDR_val <= Read ? Mdatain : BusMuxOut;
        end
    end

endmodule
