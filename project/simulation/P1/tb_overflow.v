`timescale 1ns/10ps

// Overflow Flag Testbench - Single ADD overflow demo
module tb_overflow;

    reg [31:0] A, B;
    reg [4:0] op;
    wire [63:0] C;
    wire Overflow;

    localparam OP_ADD = 5'b00000;

    alu uut (
        .A(A),
        .B(B),
        .op(op),
        .C(C),
        .Overflow(Overflow)
    );

    initial begin
        $dumpfile("overflow.vcd");
        $dumpvars(0, tb_overflow);

        $display("========================================");
        $display("Overflow Flag Testbench");
        $display("========================================\n");

        // 0x7FFFFFFF + 1 = two positives produce a negative result (OVERFLOW)
        A = 32'h7FFFFFFF; B = 32'h00000001; op = OP_ADD;
        #10;
        $display("ADD: A = %h, B = %h", A, B);
        $display("Result = %h, Overflow = %b", C[31:0], Overflow);

        $display("\n========================================");
        if (Overflow === 1'b1)
            $display("PASS: Overflow correctly detected");
        else
            $display("FAIL: Overflow was not detected");
        $display("========================================");

        #100;
        $finish;
    end

endmodule
