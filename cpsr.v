module cpsr (
    input clk,
    input rst_n,
    input en,

    input [3:0]         i_nzcv,
    output [3:0]        o_nzcv
);
    reg [3:0] nzcv;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            nzcv <= 4'b0000;
        end
        else if (en) begin
            nzcv <= i_nzcv;
        end
    end
    assign o_nzcv = nzcv;
endmodule