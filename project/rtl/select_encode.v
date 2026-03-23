module select_encode (
    input wire [31:0] IRin,
    input wire Gra, Grb, Grc,
    input wire Rin, Rout, BAout,
    // Destination register enable (wire to registers.v rin i believe)
    output wire [15:0] Rin_decoded,
    // Set control signal for bus mux, will need a module to encode to our chosen bus mux signals (save for phase 3)
    output wire [15:0] Rout_decoded,
    output wire BAout_R0
);

    wire [3:0] Ra = IRin[26:23];
    wire [3:0] Rb = IRin[22:19];
    wire [3:0] Rc = IRin[18:15];

    // Select registers
    wire [3:0] reg_sel = 
        Gra ? Ra : 
        Grb ? Rb :
        Grc ? Rc :
        4'b0000;

    reg [15:0] decoded;

    always @(*) begin
        case (reg_sel)
            4'd0: decoded = 16'b0000_0000_0000_0001;
            4'd1: decoded = 16'b0000_0000_0000_0010;
            4'd2: decoded = 16'b0000_0000_0000_0100;
            4'd3: decoded = 16'b0000_0000_0000_1000;
            4'd4: decoded = 16'b0000_0000_0001_0000;
            4'd5: decoded = 16'b0000_0000_0010_0000;
            4'd6: decoded = 16'b0000_0000_0100_0000;
            4'd7: decoded = 16'b0000_0000_1000_0000;
            4'd8: decoded = 16'b0000_0001_0000_0000;
            4'd9: decoded = 16'b0000_0010_0000_0000;
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

module extend_c (
    input wire [31:0] IRin,
    input wire Cout,
    output wire [31:0] C_extended
);

    wire sign = IRin[18];
    assign C_extended = {{13{sign}}, IRin[18:0]};

endmodule

// This encoder produces the control signal we use for bus from the output of select encoder
// Second default input allows control signal from control unit to enter bus if select encoder signal unused
module mux_encoder (
    input wire [15:0] Rout_decoded, 
    input wire [4:0] other_sel,
    output reg [4:0] mux_sel
);

    always @(*) begin
        case (Rout_decoded)
            16'b0000_0000_0000_0001: mux_sel = 5'd0;
            16'b0000_0000_0000_0010: mux_sel = 5'd1;
            16'b0000_0000_0000_0100: mux_sel = 5'd2;
            16'b0000_0000_0000_1000: mux_sel = 5'd3;
            16'b0000_0000_0001_0000: mux_sel = 5'd4;
            16'b0000_0000_0010_0000: mux_sel = 5'd5;
            16'b0000_0000_0100_0000: mux_sel = 5'd6;
            16'b0000_0000_1000_0000: mux_sel = 5'd7;
            16'b0000_0001_0000_0000: mux_sel = 5'd8;
            16'b0000_0010_0000_0000: mux_sel = 5'd9;
            16'b0000_0100_0000_0000: mux_sel = 5'd10;
            16'b0000_1000_0000_0000: mux_sel = 5'd11;
            16'b0001_0000_0000_0000: mux_sel = 5'd12;
            16'b0010_0000_0000_0000: mux_sel = 5'd13;
            16'b0100_0000_0000_0000: mux_sel = 5'd14;
            16'b1000_0000_0000_0000: mux_sel = 5'd15;
            default: mux_sel = other_sel;
        endcase
    end
 
endmodule
