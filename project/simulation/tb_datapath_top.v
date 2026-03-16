module tb_datapath_top;

  reg         clk;
  reg         reset;
  reg [15:0]  rin;
  reg [4:0]   bus_sel;
  reg [31:0]  inport_val;
  reg [31:0]  c_val;

  wire [31:0] BusMuxOut;

  // DUT
  datapath_top dut (
    .clk(clk),
    .reset(reset),
    .rin(rin),
    .bus_sel(bus_sel),
    .inport_val(inport_val),
    .c_val(c_val),
    .BusMuxOut(BusMuxOut)
  );

  // clock (10 time units)
  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    // wave dump
    $dumpfile("datapath.vcd");
    $dumpvars(0, tb_datapath_top);

    // init
    reset      = 1;
    rin        = 16'b0;
    bus_sel    = 5'd0;
    inport_val = 32'b0;
    c_val      = 32'b0;

    // reset for 2 rising edges
    repeat(2) @(posedge clk);
    reset = 0;

    // ---- Put value on InPort and select it onto bus ----
    inport_val = 32'hAAAA5555;
    bus_sel    = 5'd22;
    
    // ---- Write bus into R2 on next rising edge ----
    rin = 16'b0000_0000_0000_0100;
    @(posedge clk);
    rin = 16'b0;

    // ---- Read R2 onto bus ----
    bus_sel = 5'd2; 
    #1;

    // ---- Check ----
    if (BusMuxOut !== 32'hAAAA5555) begin
      $display("FAIL: BusMuxOut=%h (expected AAAA5555)", BusMuxOut);
    end else begin
      $display("PASS");
    end

    $finish;
  end

endmodule
