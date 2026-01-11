module uart #(
  parameter int unsigned clock_rate = 100000000,
  parameter int unsigned baud_rate = 250000,
  parameter int unsigned n_bits = 8,
  parameter int unsigned n_samples = 1
)(
  //inputs
  input clk,
  input data,
  output bit,
  output bit_ready,
  output packet_complete,
  output packet_successfull
);
  // Enums
  typedef enum logic [1:0] { 
    IDLE,
    INIT,
    READ,
    STOP
  } state_t;

  // Definitions
  localparam integer unsigned sample_count = (clock_rate / baud_rate) / n_samples;
  state_t current_state = IDLE, next_state;
  logic node_a;
  logic [sample_count-1:0] empty_count;

  counter #(.max(sample_count), .width($clog2(sample_count))) sample_clock (
    .in(clk),
    .rst(rst),
    .out(tick),
    .count(empty_count)
  );

  counter #(.max(127), .width(7)) bit_clock (
    .in(tick),
    .rst(rst),
    .out(led[7]),
    .count(led[6:0])
  );

endmodule