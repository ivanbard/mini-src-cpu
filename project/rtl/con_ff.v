module con_ff (
    input wire clk,
    input wire reset,
    input wire con_en,
    // Ra value
    input wire [31:0] BusMuxOut,
    // Condition value IR[20:19]
    input wire [1:0] c2,
    output reg con
);

    wire condition_met;

    // Decode the condition based on C2
    assign condition_met =
        (c2 == 2'b00) ? (BusMuxOut == 32'b0) : // brzr
        (c2 == 2'b01) ? (BusMuxOut != 32'b0) : // brnz
        (c2 == 2'b10) ? (~BusMuxOut[31]) :     // brpl
                        ( BusMuxOut[31]);      // brmi

    // Set output to let control unit know if branch occurs
    always @(posedge clk or posedge reset) begin
        if (reset)
            con <= 1'b0;
        else if (con_en)
            con <= condition_met;
    end

endmodule