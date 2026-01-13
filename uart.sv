module uart #(
  parameter int unsigned clock_rate = 100000000,
  parameter int unsigned baud_rate = 250000,
  parameter int unsigned n_bits = 8,
  parameter int unsigned n_samples = 1
)(
  //inputs
  input clk,
  input data,
  output reg bit_output,
  output reg bit_ready,
  output reg packet_complete,
  output reg packet_successfull
);
  // Enums
  typedef enum logic [1:0] { 
    IDLE,
    INIT,
    READ,
    STOP
  } state_t;

  // Definitions
  localparam integer unsigned rate_ratio = clock_rate / baud_rate; // Ratio of clock to baud
  localparam integer unsigned sample_count = rate_ratio / n_samples; // Amount of clock cycles per sample
  localparam integer unsigned delay_cycles = (1/(clock_rate/rate_ratio))*(1+1/(n_samples+1)); // Amount of clock cycles to wait before sampling
  state_t current_state = IDLE, next_state; // Initial states
  logic delay_reset, delay_out, sample_reset, sample_out, bit_reset, bit_out, data_reset, data_out; // Counter connections
  logic [$clog2(delay_cycles):0] empty_1; // Delay clock empty connection
  logic [$clog2(sample_count):0] empty_2; // Sample clock empty connection
  logic [$clog2(n_samples):0] empty_3; // Bit clock empty connection
  logic [$clog2(n_bits):0] empty_4; // Data clock empty connection
  logic [$clog2(n_samples):0] bit_value; // Accumulated value of a single bit

  // Modules
  counter #(.max(delay_cycles), .width($clog2(delay_cycles))) delay_clock (
    .in(clk),
    .rst(delay_reset),
    .out(delay_out),
    .count(empty_1)
  );

  counter #(.max(sample_count), .width($clog2(sample_count))) sample_clock (
    .in(clk),
    .rst(sample_reset),
    .out(sample_out),
    .count(empty_2)
  );

  counter #(.max(n_samples), .width($clog2(n_samples))) bit_clock (
    .in(sample_out),
    .rst(bit_reset),
    .out(bit_out),
    .count(empty_3)
  );

  counter #(.max(n_bits), .width($clog2(n_bits))) data_clock (
    .in(bit_out),
    .rst(data_reset),
    .out(data_out),
    .count(empty_4)
  );

  always_ff @(posedge clk) begin
    current_state <= next_state;
    bit_ready <= 0;
    delay_reset <= 0;
    sample_reset <= 0;
    bit_reset <= 0;
    data_reset <= 0;
    packet_complete <= 0;
    packet_successfull <= 0;

    case(current_state)
      IDLE: begin
        if (!data) begin
          delay_reset <= 1;
          next_state <= INIT;
        end
        else begin
          bit_value <= 0;
          next_state <= IDLE;
        end
      end

      INIT: begin
        if (delay_out) begin
          sample_reset <= 1;
          bit_reset <= 1;
          data_reset <= 1;
          bit_value <= 0;
          next_state <= READ;
        end
        else
          next_state <= INIT;
      end

      READ: begin
        if (sample_out)
          bit_value <= bit_value + data;
        
        if (bit_out)begin
          bit_ready <= 1;
          if (bit_value >= (n_samples[$clog2(n_samples):0] >> 1))
            bit_output <= 1;
          else
            bit_output <= 0;
          bit_value <= 0;
        end

        if (data_out)begin
          next_state <= STOP;
          bit_value <= 0;
          sample_reset <= 1;
          bit_reset <= 1;
          data_reset <= 1;
        end
        else
          next_state <= READ;
      end

      STOP: begin
        if (sample_out)
          bit_value <= bit_value + data;
        
        if (bit_out)begin
          if (bit_value >= (n_samples[$clog2(n_samples):0] >> 1))
            packet_successfull <= 0;
          else
            packet_successfull <= 1;
          next_state <= IDLE;
        end
      end
    endcase
  end
endmodule