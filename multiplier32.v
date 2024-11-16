module multiplier32 (
    input clk,
    input rst_n,

    input           i_vld,
    input           i_sign,
    input [31:0]    i_op1,
    input [31:0]    i_op2,
    input [63:0]    i_acc,

    output          o_vld,
    output [63:0]   o_result
);
    /*
        WARNING:
        For logic testing only.
    */
    reg [63:0] result;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result <= 'b0;
        end
        else begin
            if (i_vld) begin
                if (i_sign) begin
                    result <= $signed({{32{i_op1[31]}}, i_op1}) * $signed({{32{i_op2[31]}}, i_op2}) + i_acc;
                end
                else begin
                    result <= i_op1 * i_op2 + i_acc;
                end
            end
        end
    end
    assign o_vld = ~i_vld;
    assign o_result = result;
endmodule