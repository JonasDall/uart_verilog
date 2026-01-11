`default_nettype none
`timescale 10 ns / 1 ns

module uart_tb;

  // Input.
  logic clk = 0;
  logic rst;
  logic tick;
  logic [2:0] count;

  counter #(.max(3), .width(3)) counter_1 (
    .in(clk),
    .rst(rst),
    .out(tick),
    .count(count)
  );

  initial begin
    // Dump vars to the output .vcd file
    $dumpvars(0, uart_tb);

    rst = 1;
    #1 rst = 0;

    repeat (50) begin
      $display("%0d", tick);
      #10 clk = ~clk;
      $display("%0d", tick);
    end

    $display("End of simulation");
    $finish;
  end

endmodule
