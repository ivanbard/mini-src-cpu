module tb_regfile16;
    reg clk;
    reg reset;
    reg [15:0] rin;
    reg [15:0] rout;
    reg [31:0] bus;

    wire [31:0] bus_out;
    wire [31:0] r2_out; //testing r2 in here for now

    regfile16 dut(
        .clk(clk),
        .reset(reset),
        .rin(rin),
        .bus(bus),
        .rout(rout),
        .bus_out(bus_out),
        .r2_out(r2_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

endmodule