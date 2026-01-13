module counter #( // Emits a rising edge when the count is reached
    parameter int unsigned max,
    parameter int unsigned width
)(
    input logic in,
    input logic rst,
    output logic out = 0,
    output logic [width:0] count
);
    logic [width:0] max_u;
    assign max_u = logic'(max);

    always_ff @(posedge in or posedge rst) begin
        if (rst) begin
            count <= 0;
            out <= 0;
        end
        else begin
            if (count >= max_u) begin
                count <= 0;
                out <= 1;
            end
            else begin
                count <= count + 1;
                out <= 0;
            end
        end
    end
endmodule