module swp_ctrl (
    input clk,
    input rst_n,
    input en,
    input       i_swp_vld,
    output reg  o_swp_hold
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_swp_hold <= 'b0;
        end
        else if (en) begin
            if (o_swp_hold) begin
                o_swp_hold <= 'b0;
            end
            else begin
                o_swp_hold <= i_swp_vld;
            end
        end
    end
endmodule