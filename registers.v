/*
width = 32 bits

Inputs:
    clock
    reset
    enable
    data in

Outputs:
    stored value

*/

// one single 32 bit register
module reg32 (
    input wire clk,
    input wire reset,
    input wire en,
    input wire [31:0] d_in,
    output reg [31:0] d_out //32 flip flops
);

    always @(posedge clk) begin
        if (reset)
            q <= 32'b0; //clear flip flops if reset = 1
        else if (en)
            q <= d; //put data in into flip flops if enable = 1
        //otherwise q stays same
    end

endmodule