module extend_c (
    input wire [31:0] IRin,
    input wire Cout,
    output wire [31:0] C_extended
);

    wire sign = IRin[18];
    assign C_extended = Cout ? {{13{sign}}, IRin[18:0]} : {13'b0, IRin[18:0]};

endmodule