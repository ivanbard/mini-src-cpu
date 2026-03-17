// RAM Module
//
// Sync write, async read

module ram (
    input wire clk,     
    input wire ram_read, // 1 from memory, 0 to memory
    input wire ram_en,
    input wire [8:0] ram_addr,
    input wire [31:0] ram_in,  
    output wire [31:0] ram_val
);

    reg [31:0] mem [0:511];

    integer i;
    initial begin
        for (i = 0; i < 512; i = i + 1)
            mem[i] = 32'h00000000;
    end

    always @(posedge clk) begin
        if (ram_en && !ram_read)
            mem[ram_addr] <= ram_in;
    end

    assign ram_val = (ram_en && ram_read) ? mem[ram_addr] : 32'b0;

endmodule
