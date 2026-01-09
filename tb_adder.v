module tb_adder;
    reg  [3:0] a, b;
    wire [4:0] sum;

    adder dut(.a(a), .b(b), .sum(sum));

    initial begin
        $dumpfile("adder.vcd");
        $dumpvars(0, tb_adder);

        a = 4'd3; b = 4'd5; #10;
        a = 4'd7; b = 4'd8; #10;
        a = 4'd15; b = 4'd1; #10;

        $finish;
    end
endmodule
