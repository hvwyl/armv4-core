module wb_stage (
    /* from upper pipeline */
    input [31:0]        i_wb_op,
    input               i_wb_rd_src,
    input               i_wb_rd_vld,
    input [3:0]         i_wb_rd_code,

    /* from mem ctrl */
    input [31:0]        i_memctrl_rdata,

    output              o_rd_en_wb,
    output [3:0]        o_rd_code_wb,
    output [31:0]       o_rd_reg_wb
);
    assign o_rd_en_wb = i_wb_rd_vld;
    assign o_rd_code_wb = i_wb_rd_code;
    assign o_rd_reg_wb = i_wb_rd_src?(i_memctrl_rdata):(i_wb_op);
endmodule