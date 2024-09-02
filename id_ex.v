module id_ex (
    input clk,
    input rst_n,
    input en,

    input [31:0]        i_op1,
    input [31:0]        i_op2,
    input [7:0]         i_shift,
    input [2:0]         i_shift_type,
    input [31:0]        i_op3,
    input [3:0]         i_opcode,
    input               i_mem_vld,
    input [1:0]         i_mem_size,
    input               i_mem_sign,
    input               i_mem_addr_src,
    input               i_rd_vld,
    input [3:0]         i_rd_code,
    input               i_wb_rd_vld,
    input [3:0]         i_wb_rd_code,
    input               i_nzcv_flag,
    input               i_is_swp,
    input               i_is_ldm,

    output reg [31:0]   o_op1,
    output reg [31:0]   o_op2,
    output reg [7:0]    o_shift,
    output reg [2:0]    o_shift_type,
    output reg [31:0]   o_op3,
    output reg [3:0]    o_opcode,
    output reg          o_mem_vld,
    output reg [1:0]    o_mem_size,
    output reg          o_mem_sign,
    output reg          o_mem_addr_src,
    output reg          o_rd_vld,
    output reg [3:0]    o_rd_code,
    output reg          o_wb_rd_vld,
    output reg [3:0]    o_wb_rd_code,
    output reg          o_nzcv_flag,
    output reg          o_is_swp,
    output reg          o_is_ldm

);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_op1           <= 'b0;
            o_op2           <= 'b0;
            o_shift         <= 'b0;
            o_shift_type    <= 'b0;
            o_op3           <= 'b0;
            o_opcode        <= 'b0;
            o_mem_vld       <= 'b0;
            o_mem_size      <= 'b0;
            o_mem_sign      <= 'b0;
            o_mem_addr_src  <= 'b0;
            o_rd_vld        <= 'b0;
            o_rd_code       <= 'b0;
            o_wb_rd_vld     <= 'b0;
            o_wb_rd_code    <= 'b0;
            o_nzcv_flag     <= 'b0;
            o_is_swp        <= 'b0;
            o_is_ldm        <= 'b0;
        end
        else if (en) begin
            o_op1           <= i_op1           ;
            o_op2           <= i_op2           ;
            o_shift         <= i_shift         ;
            o_shift_type    <= i_shift_type    ;
            o_op3           <= i_op3           ;
            o_opcode        <= i_opcode        ;
            o_mem_vld       <= i_mem_vld       ;
            o_mem_size      <= i_mem_size      ;
            o_mem_sign      <= i_mem_sign      ;
            o_mem_addr_src  <= i_mem_addr_src  ;
            o_rd_vld        <= i_rd_vld        ;
            o_rd_code       <= i_rd_code       ;
            o_wb_rd_vld     <= i_wb_rd_vld     ;
            o_wb_rd_code    <= i_wb_rd_code    ;
            o_nzcv_flag     <= i_nzcv_flag     ;
            o_is_swp        <= i_is_swp        ;
            o_is_ldm        <= i_is_ldm        ;
        end
    end
endmodule