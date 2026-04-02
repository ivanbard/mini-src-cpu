module seven_seg (
    input  wire [3:0] data,
    output reg  [6:0] outputt
);
    always @(*) begin
        case (data)
            4'h0: outputt = 7'b1000000; // 0
            4'h1: outputt = 7'b1111001; // 1
            4'h2: outputt = 7'b0100100; // 2
            4'h3: outputt = 7'b0110000; // 3
            4'h4: outputt = 7'b0011001; // 4
            4'h5: outputt = 7'b0010010; // 5
            4'h6: outputt = 7'b0000010; // 6
            4'h7: outputt = 7'b1111000; // 7
            4'h8: outputt = 7'b0000000; // 8
            4'h9: outputt = 7'b0010000; // 9
            4'ha: outputt = 7'b0001000; // A
            4'hb: outputt = 7'b0000011; // b
            4'hc: outputt = 7'b1000110; // C
            4'hd: outputt = 7'b0100001; // d
            4'he: outputt = 7'b0000110; // E
            4'hf: outputt = 7'b0001110; // F
            default: outputt = 7'b1111111; // all off
        endcase
    end
endmodule
