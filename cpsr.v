module cpsr (
    input clk,
    input rst_n,
    input en,

    input               i_nzcv_flag,
    input [3:0]         i_nzcv_alu,

    output [3:0]        o_nzcv,
    output [3:0]        o_nzcv_next
);
    reg [3:0] nzcv;
    reg [3:0] nzcv_next;
    always @(*) begin
        if (i_nzcv_flag) begin
            nzcv_next <= i_nzcv_alu;
        end
        else begin
            nzcv_next <= nzcv;
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            nzcv <= 4'b0000;
        end
        else if (en) begin
            nzcv <= nzcv_next;
        end
    end
    assign o_nzcv = nzcv;
    assign o_nzcv_next = nzcv_next;
endmodule