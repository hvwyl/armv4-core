module forward_ex_ctrl (
    /* WB phase write register */
    input               i_rd_en_wb,
    input [3:0]         i_rd_code_wb,
    input [31:0]        i_rd_reg_wb,

    /* register code input */
    input [3:0]         i_re_code,

    /* register input */
    input [31:0]        i_re_reg,

    /* register output */
    output reg [31:0]   o_re_reg
);
    always @(*) begin
        if (i_rd_en_wb & (i_rd_code_wb == i_re_code)) begin
            o_re_reg = i_rd_reg_wb;
        end
        else begin
            o_re_reg = i_re_reg;
        end
    end
endmodule