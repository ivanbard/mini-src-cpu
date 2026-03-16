module outport (
    input wire clk,
    input wire reset,
    input wire outport_in,
    input wire [31:0] BusMuxOut,
    output reg [31:0] outport_val
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            outport_val <= 32'b0;
        else if (outport_in)
            outport_val <= BusMuxOut;
    end

endmodule

module inport (
    input wire clk,
    input wire reset,
    input wire inport_in, 
    input wire [31:0] device_in, 
    output reg [31:0] inport_val
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            inport_val <= 32'b0;
        else if (inport_in)
            inport_val <= device_in;
    end

endmodule