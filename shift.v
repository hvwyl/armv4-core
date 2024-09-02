module shift #(
    parameter DATA_WIDTH = 32,
    parameter SHIFT_TYPE = "LSL"
) (
    input [DATA_WIDTH-1:0]          i_op,
    input [$clog2(DATA_WIDTH)-1:0]  i_amount,
    input                           i_carry,
    output [DATA_WIDTH-1:0]         o_result,
    output                          o_carry
);
    wire [DATA_WIDTH-1:0] sr [DATA_WIDTH-1:0];  // shift result
    wire [DATA_WIDTH-1:0] cr;                   // carry result
    genvar i;
    generate
        for (i = 0; i<DATA_WIDTH; i=i+1) begin
            if (i == 0) begin
                assign sr[i] = i_op[DATA_WIDTH-1:0];
                assign cr[i] = i_carry;
            end
            else begin
                case (SHIFT_TYPE)
                    "LSL": begin
                        assign sr[i] = {i_op[DATA_WIDTH-1-i:0], {(i){1'b0}}}; 
                        assign cr[i] = i_op[DATA_WIDTH-i];
                    end
                    "LSR": begin
                        assign sr[i] = {{(i){1'b0}}, i_op[DATA_WIDTH-1:i]}; 
                        assign cr[i] = i_op[i-1];
                    end
                    "ASR": begin
                        assign sr[i] = {{(i){i_op[DATA_WIDTH-1]}}, i_op[DATA_WIDTH-1:i]}; 
                        assign cr[i] = i_op[i-1];
                    end
                    "ROR": begin
                        assign sr[i] = {i_op[i-1:0], i_op[DATA_WIDTH-1:i]}; 
                        assign cr[i] = i_op[i-1];
                    end
                endcase
            end
        end
    endgenerate
    assign o_result = sr[i_amount];
    assign o_carry = cr[i_amount];
endmodule