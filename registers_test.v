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

    initial begin
        reset = 1;
        rin = 16'b0;
        rout = 16'b0;
        bus = 32'b0;

        //hold reset for 2 rising edges to be safe
        repeat(2) @(posedge clk);
        reset = 0;

        // WRITE TO R2
        bus = 32'hAAAA5555; //put in the hex we want to put into r2
        rin =16'b0000_0000_0000_0100; //enable r2 in the in
        @(posedge clk);
        rin = 16'b0; //stop write

        // READ FROM R2
        rout = 16'b0000_0000_0000_0100;
        #1; //small delay to be safe for the mux

        if (bus_out !== 32'hAAAA5555) $display("error: bus_out=%h", bus_out);
        else $display("works")
        $finish
    end

endmodule