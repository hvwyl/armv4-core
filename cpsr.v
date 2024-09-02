module cpsr (
    input clk,
    input rst_n,
    input en,

    input [3:0]         i_nzcv,
    output reg [3:0]    o_nzcv
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_nzcv <= 4'b0000;
        end
        else if (en) begin
            o_nzcv <= i_nzcv;
        end
    end
endmodule