`include "def.v"
module ex_stage (
    /* CPSR */
    input [3:0]         i_nzcv,
    output [3:0]        o_nzcv_alu,

    /* to registers */
    output              o_rd_en_ex,
    output [3:0]        o_rd_code_ex,
    output [31:0]       o_rd_reg_ex,

    /* to mem ctrl */
    output              o_memctrl_vld,
    output              o_memctrl_wr,
    output              o_memctrl_sign,
    output [1:0]        o_memctrl_size,
    output [31:0]       o_memctrl_addr,
    output [31:0]       o_memctrl_wdata,

    /* from upper pipeline */
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
    
    /* to next pipeline */
    output [31:0]       o_wb_op,
    output              o_wb_rd_src,
    output              o_wb_rd_vld,
    output [3:0]        o_wb_rd_code
);
    /*
        (shift_result, shift_carry) = Shift_C(i_op1, i_shift_type, i_shift, CPSR.C);
        (alu_result, alu_nzcv) = ALU(shift_result, i_opcode, i_op2, (i_nzcv, shift_carry));
    */
    wire [31:0] shift_result;
    wire shift_carry;
    wire [31:0] alu_result;
    shift_unit shift_unit_0(
        .i_op       (i_op2),
        .i_type     (i_shift_type),
        .i_amount   (i_shift),
        .i_carry    (i_nzcv[1]),
        .o_result   (shift_result),
        .o_carry    (shift_carry)
    );
    alu alu_0(
        .i_opcode       (i_opcode),
        .i_nzcv         (i_nzcv),
        .i_op1          (i_op1),
        .i_op2          (shift_result),
        .i_shift_carry  (shift_carry),
        .o_nzcv         (o_nzcv_alu),
        .o_result       (alu_result)
    );

    /* to registers */
    assign o_rd_en_ex = i_rd_vld;
    assign o_rd_code_ex = i_rd_code;
    assign o_rd_reg_ex = alu_result;
    
    /* to mem ctrl */
    assign o_memctrl_vld = i_mem_vld;
    assign o_memctrl_wr = (~i_wb_rd_vld);   // STR instruction wrtie register in WB phase
    assign o_memctrl_sign = i_mem_sign;
    assign o_memctrl_size = i_mem_size;
    assign o_memctrl_addr = i_mem_addr_src?alu_result:i_op1;    // P=1:ALU result used as mem address, P=0:op1 used as mem address
    assign o_memctrl_wdata = i_op3;

    /* to next pipeline */
    assign o_wb_op = i_op3;                 // BL instruction write LR register in WB phase, LDM write the same value in register directly
    assign o_wb_rd_src = i_mem_vld;         // BL instruction do not enable mem, LDM write the same value in register directly
    assign o_wb_rd_vld = i_wb_rd_vld;
    assign o_wb_rd_code = i_wb_rd_code;
    
endmodule