`timescale 1ns/10ps

// Comprehensive ALU Testbench
module tb_alu;

    reg [31:0] A, B;
    reg [4:0] op;
    wire [63:0] C;

    // Operation codes (must match alu.v)
    localparam OP_ADD  = 5'b00000;
    localparam OP_SUB  = 5'b00001;
    localparam OP_MUL  = 5'b00010;
    localparam OP_DIV  = 5'b00011;
    localparam OP_AND  = 5'b00100;
    localparam OP_OR   = 5'b00101;
    localparam OP_NOT  = 5'b00110;
    localparam OP_NEG  = 5'b00111;
    localparam OP_SHR  = 5'b01000;
    localparam OP_SHRA = 5'b01001;
    localparam OP_SHL  = 5'b01010;
    localparam OP_ROR  = 5'b01011;
    localparam OP_ROL  = 5'b01100;

    // Instantiate ALU
    alu uut (
        .A(A),
        .B(B),
        .op(op),
        .C(C)
    );

    integer pass_count = 0;
    integer fail_count = 0;

    // Test helper task
    task check_result;
        input [63:0] expected;
        input [127:0] test_name;  // 16 character string
        begin
            #10;  // Allow propagation
            if (C === expected) begin
                $display("PASS: %s - Expected: 0x%016h, Got: 0x%016h", test_name, expected, C);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %s - Expected: 0x%016h, Got: 0x%016h", test_name, expected, C);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("alu.vcd");
        $dumpvars(0, tb_alu);
        
        $display("========================================");
        $display("ALU Testbench - Mini SRC Phase 1");
        $display("========================================\n");

        // =============================================
        // Test AND Operation
        // =============================================
        $display("--- Testing AND ---");
        A = 32'hFF00FF00; B = 32'h0F0F0F0F; op = OP_AND;
        check_result(64'h000000000F000F00, "AND basic");
        
        A = 32'hFFFFFFFF; B = 32'h12345678; op = OP_AND;
        check_result(64'h0000000012345678, "AND with all 1s");
        
        A = 32'h00000000; B = 32'h12345678; op = OP_AND;
        check_result(64'h0000000000000000, "AND with zero");

        // =============================================
        // Test OR Operation
        // =============================================
        $display("\n--- Testing OR ---");
        A = 32'hFF00FF00; B = 32'h00FF00FF; op = OP_OR;
        check_result(64'h00000000FFFFFFFF, "OR basic");
        
        A = 32'h00000000; B = 32'h12345678; op = OP_OR;
        check_result(64'h0000000012345678, "OR with zero");

        // =============================================
        // Test NOT Operation
        // =============================================
        $display("\n--- Testing NOT ---");
        A = 32'h00000000; B = 32'h00000000; op = OP_NOT;
        check_result(64'h00000000FFFFFFFF, "NOT zero");
        
        A = 32'h00000000; B = 32'hFFFFFFFF; op = OP_NOT;
        check_result(64'h0000000000000000, "NOT all ones");
        
        A = 32'h00000000; B = 32'h12345678; op = OP_NOT;
        check_result(64'h00000000EDCBA987, "NOT pattern");

        // =============================================
        // Test NEG Operation
        // =============================================
        $display("\n--- Testing NEG ---");
        A = 32'h00000000; B = 32'h00000001; op = OP_NEG;
        check_result(64'h00000000FFFFFFFF, "NEG 1");
        
        A = 32'h00000000; B = 32'h00000005; op = OP_NEG;
        check_result(64'h00000000FFFFFFFB, "NEG 5");
        
        A = 32'h00000000; B = 32'hFFFFFFFF; op = OP_NEG;  // -1
        check_result(64'h0000000000000001, "NEG -1");

        // =============================================
        // Test ADD Operation
        // =============================================
        $display("\n--- Testing ADD ---");
        A = 32'h00000005; B = 32'h00000003; op = OP_ADD;
        check_result(64'h0000000000000008, "ADD 5+3");
        
        A = 32'hFFFFFFFF; B = 32'h00000001; op = OP_ADD;
        check_result(64'h0000000000000000, "ADD overflow");
        
        A = 32'h12345678; B = 32'h87654321; op = OP_ADD;
        check_result(64'h0000000099999999, "ADD large");

        // =============================================
        // Test SUB Operation
        // =============================================
        $display("\n--- Testing SUB ---");
        A = 32'h00000008; B = 32'h00000003; op = OP_SUB;
        check_result(64'h0000000000000005, "SUB 8-3");
        
        A = 32'h00000003; B = 32'h00000005; op = OP_SUB;
        check_result(64'h00000000FFFFFFFE, "SUB 3-5 (neg)");
        
        A = 32'h00000000; B = 32'h00000001; op = OP_SUB;
        check_result(64'h00000000FFFFFFFF, "SUB 0-1");

        // =============================================
        // Test SHL Operation
        // =============================================
        $display("\n--- Testing SHL ---");
        A = 32'h00000001; B = 32'h00000004; op = OP_SHL;
        check_result(64'h0000000000000010, "SHL 1<<4");
        
        A = 32'hF0000000; B = 32'h00000004; op = OP_SHL;
        check_result(64'h0000000000000000, "SHL overflow");
        
        A = 32'h12345678; B = 32'h00000008; op = OP_SHL;
        check_result(64'h0000000034567800, "SHL by 8");

        // =============================================
        // Test SHR Operation
        // =============================================
        $display("\n--- Testing SHR ---");
        A = 32'h00000010; B = 32'h00000004; op = OP_SHR;
        check_result(64'h0000000000000001, "SHR 16>>4");
        
        A = 32'hF0000000; B = 32'h00000004; op = OP_SHR;
        check_result(64'h000000000F000000, "SHR unsigned");
        
        A = 32'h12345678; B = 32'h00000008; op = OP_SHR;
        check_result(64'h0000000000123456, "SHR by 8");

        // =============================================
        // Test SHRA Operation
        // =============================================
        $display("\n--- Testing SHRA ---");
        A = 32'hF0000000; B = 32'h00000004; op = OP_SHRA;
        check_result(64'h00000000FF000000, "SHRA neg sign ext");
        
        A = 32'h70000000; B = 32'h00000004; op = OP_SHRA;
        check_result(64'h0000000007000000, "SHRA pos no ext");
        
        A = 32'h80000000; B = 32'h0000001F; op = OP_SHRA;
        check_result(64'h00000000FFFFFFFF, "SHRA max shift neg");

        // =============================================
        // Test ROR Operation
        // =============================================
        $display("\n--- Testing ROR ---");
        A = 32'h00000001; B = 32'h00000001; op = OP_ROR;
        check_result(64'h0000000080000000, "ROR 1 by 1");
        
        A = 32'h80000001; B = 32'h00000001; op = OP_ROR;
        check_result(64'h00000000C0000000, "ROR pattern");
        
        A = 32'h12345678; B = 32'h00000004; op = OP_ROR;
        check_result(64'h0000000081234567, "ROR by 4");

        // =============================================
        // Test ROL Operation
        // =============================================
        $display("\n--- Testing ROL ---");
        A = 32'h80000000; B = 32'h00000001; op = OP_ROL;
        check_result(64'h0000000000000001, "ROL MSB to LSB");
        
        A = 32'h00000001; B = 32'h00000004; op = OP_ROL;
        check_result(64'h0000000000000010, "ROL 1 by 4");
        
        A = 32'h12345678; B = 32'h00000004; op = OP_ROL;
        check_result(64'h0000000023456781, "ROL by 4");

        // =============================================
        // Test MUL Operation
        // =============================================
        $display("\n--- Testing MUL ---");
        A = 32'h00000005; B = 32'h00000003; op = OP_MUL;
        check_result(64'h000000000000000F, "MUL 5*3");
        
        A = 32'h00001000; B = 32'h00001000; op = OP_MUL;
        check_result(64'h0000000001000000, "MUL 4096*4096");
        
        A = 32'hFFFFFFFF; B = 32'hFFFFFFFF; op = OP_MUL;  // -1 * -1 = 1
        check_result(64'h0000000000000001, "MUL -1*-1");
        
        A = 32'hFFFFFFFF; B = 32'h00000002; op = OP_MUL;  // -1 * 2 = -2
        check_result(64'hFFFFFFFFFFFFFFFE, "MUL -1*2");
        
        A = 32'h00010000; B = 32'h00010000; op = OP_MUL;  // 65536 * 65536
        check_result(64'h0000000100000000, "MUL large 64-bit");

        // =============================================
        // Test DIV Operation
        // =============================================
        $display("\n--- Testing DIV ---");
        A = 32'h0000000F; B = 32'h00000003; op = OP_DIV;  // 15/3 = 5 rem 0
        check_result(64'h0000000000000005, "DIV 15/3");
        
        A = 32'h00000011; B = 32'h00000005; op = OP_DIV;  // 17/5 = 3 rem 2
        #10;
        if (C[31:0] == 32'h00000003 && C[63:32] == 32'h00000002) begin
            $display("PASS: DIV 17/5 - Quotient: %d, Remainder: %d", C[31:0], C[63:32]);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: DIV 17/5 - Expected Q=3 R=2, Got Q=%d R=%d", C[31:0], C[63:32]);
            fail_count = fail_count + 1;
        end
        
        A = 32'h00000064; B = 32'h0000000A; op = OP_DIV;  // 100/10 = 10 rem 0
        check_result(64'h000000000000000A, "DIV 100/10");

        // =============================================
        // Summary
        // =============================================
        $display("\n========================================");
        $display("Test Summary: %0d PASSED, %0d FAILED", pass_count, fail_count);
        $display("========================================");
        
        #100;
        $finish;
    end

endmodule
