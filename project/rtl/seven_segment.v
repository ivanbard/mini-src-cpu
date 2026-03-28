module seven_seg (
    input  wire [3:0] data,
    output reg  [7:0] outputt
);
    always @(*) begin
        case (data)
            4'h0: outputt = 8'b11000000; // 0
            4'h1: outputt = 8'b11111001; // 1
            4'h2: outputt = 8'b10100100; // 2
            4'h3: outputt = 8'b10110000; // 3
            4'h4: outputt = 8'b10011001; // 4
            4'h5: outputt = 8'b10010010; // 5
            4'h6: outputt = 8'b10000010; // 6
            4'h7: outputt = 8'b11111000; // 7
            4'h8: outputt = 8'b10000000; // 8
            4'h9: outputt = 8'b10010000; // 9
            4'ha: outputt = 8'b10001000; // A
            4'hb: outputt = 8'b10000011; // b
            4'hc: outputt = 8'b11000110; // C
            4'hd: outputt = 8'b10100001; // d
            4'he: outputt = 8'b10000110; // E
            4'hf: outputt = 8'b10001110; // F
            default: outputt = 8'b11111111; // all off
        endcase
    end
endmodule