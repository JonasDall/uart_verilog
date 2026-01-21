`default_nettype none
`timescale 1ns/1ps

module uart_rx_tb;
  // Input
  logic clk = 1'b0;
  logic rx = 1'b1;
  logic ready;
  logic success;
  logic [7:0] data;

  parameter CLOCK_RATE = 100_000_000;
  parameter BAUD_RATE = 250_000;

  uart_rx #(
    .CLOCK_BAUD_RATIO(CLOCK_RATE/BAUD_RATE),
    .BIT_WIDTH(9)
  ) uart_rx_1 (
    .clk(clk),
    .rx(rx),
    .ready(ready),
    .success(success),
    .data(data)
  );

  initial begin
    // Dump vars to the output .vcd file
    $dumpvars(0, uart_rx_tb);

    repeat (11000) begin
      #5 clk = ~clk;
    end

    $display("End of simulation");
    $finish;
  end

  initial begin
    #8000 rx = 1'b0;
    #4000 rx = 1'b1;
    #4000 rx = 1'b1;
    #4000 rx = 1'b0;
    #4000 rx = 1'b0;
    #4000 rx = 1'b1;
    #4000 rx = 1'b1;
    #4000 rx = 1'b0;
    #4000 rx = 1'b0;
    #4000 rx = 1'b1;
    #4000 rx = 1'b1;
  end

endmodule
