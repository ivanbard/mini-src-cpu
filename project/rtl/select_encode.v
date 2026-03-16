module select_encode (
    input wire [31:0] IRin,
    input wire Gra, Grb, Grc,
    input wire Rin, Rout, BAout,
    // Destination register enable (wire to registers.v rin i believe)
    output wire [15:0] Rin_decoded,
    // Set control signal for bus mux, will need a module to encode to our chosen bus mux signals
    output wire [15:0] Rout_decoded,
    output wire BAout_R0
);

    wire [3:0] Ra = IRin[26:23];
    wire [3:0] Rb = IRin[22:19];
    wire [3:0] Rc = IRin[18:15];

    // select registers
    wire [3:0] reg_sel = 
        Gra ? Ra : 
        Grb ? Rb :
        Grc ? Rc :
        4'b0000;

    reg [15:0] decoded;

    always @(*) begin
        case (reg_sel)
            4'd0:  decoded = 16'b0000_0000_0000_0001;
            4'd1:  decoded = 16'b0000_0000_0000_0010;
            4'd2:  decoded = 16'b0000_0000_0000_0100;
            4'd3:  decoded = 16'b0000_0000_0000_1000;
            4'd4:  decoded = 16'b0000_0000_0001_0000;
            4'd5:  decoded = 16'b0000_0000_0010_0000;
            4'd6:  decoded = 16'b0000_0000_0100_0000;
            4'd7:  decoded = 16'b0000_0000_1000_0000;
            4'd8:  decoded = 16'b0000_0001_0000_0000;
            4'd9:  decoded = 16'b0000_0010_0000_0000;
            4'd10: decoded = 16'b0000_0100_0000_0000;
            4'd11: decoded = 16'b0000_1000_0000_0000;
            4'd12: decoded = 16'b0001_0000_0000_0000;
            4'd13: decoded = 16'b0010_0000_0000_0000;
            4'd14: decoded = 16'b0100_0000_0000_0000;
            4'd15: decoded = 16'b1000_0000_0000_0000;
            default: decoded = 16'b0000_0000_0000_0000;
        endcase
    end

    assign Rin_decoded  = decoded & {16{Rin}};
    assign Rout_decoded = decoded & {16{Rout}};
    assign BAout_R0 = BAout & decoded[0];
    
endmodule
