module ex_wb (
    input clk,
    input rst_n,
    input en,
    
    input [31:0]        i_wb_op,
    input               i_wb_rd_src,
    input               i_wb_rd_vld,
    input [3:0]         i_wb_rd_code,

    output reg[31:0]    o_wb_op,
    output reg          o_wb_rd_src,
    output reg          o_wb_rd_vld,
    output reg [3:0]    o_wb_rd_code

    /* other signal will generate by mem ctrl */
    
);
    /*
        instruction in WB phase will unconditional execution
    */
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_wb_op         <=  'b0;
            o_wb_rd_src     <=  'b0;
            o_wb_rd_vld     <=  'b0;
            o_wb_rd_code    <=  'b0;
        end
        else if (en) begin
            o_wb_op         <=  i_wb_op      ;
            o_wb_rd_src     <=  i_wb_rd_src  ;
            o_wb_rd_vld     <=  i_wb_rd_vld  ;
            o_wb_rd_code    <=  i_wb_rd_code ;
        end
    end
endmodule