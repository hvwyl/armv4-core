`include "def.v"
module ex_stage (
    /* CPSR */
    input [3:0]         i_nzcv,
    output [3:0]        o_nzcv_alu,

    /* xPSR registers */
    output              o_xpsr_en_ex,
    output              o_xpsr_sel, // S=0: CPSR, S=1: SPSR
    output [31:0]       o_xpsr_reg,
    input [31:0]        i_xpsr_reg,

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

    /* from mul ctrl */
    input               i_mul_result_vld,
    input [31:0]        i_mul_result_lo,
    input [31:0]        i_mul_result_hi,

    /* from swp ctrl */
    input               i_swp_hold,

    /* from ldm ctrl */
    input [31:0]        i_ldm_offset,
    input               i_ldm_mem_vld,
    input [3:0]         i_ldm_reg_code,
    input [31:0]        i_ldm_reg,

    /* multiplier control signals */
    input               i_mul_vld,
    input               i_mul_lmode,

    /* high-priority function control signals */
    input               i_swp_vld,       // SWP instruction
    input               i_ldm_vld,       // LDM instruction
    input               i_mrs_vld,
    input               i_msr_vld,
    
    /* to next pipeline */
    output [31:0]       o_wb_op,
    output              o_wb_rd_src,
    output              o_wb_rd_vld,
    output [3:0]        o_wb_rd_code
);
    /* EX stage multiplexing definitions */
    reg [31:0] muxed_op2;
    always @(*) begin
        if (i_ldm_vld) begin
            muxed_op2 = i_ldm_offset;
        end
        else begin
            muxed_op2 = i_op2;
        end
    end

    reg [31:0] muxed_op3;
    always @(*) begin
        case ({i_mul_vld, i_ldm_vld})
            'b01: muxed_op3 = i_ldm_reg;
            'b10: muxed_op3 = i_mul_result_hi;
            default: muxed_op3 = i_op3;
        endcase
    end

    reg muxed_mem_vld;
    always @(*) begin
        if (i_ldm_vld) begin
            muxed_mem_vld = i_ldm_mem_vld;
        end
        else begin
            muxed_mem_vld = i_mem_vld;
        end
    end

    reg muxed_wb_rd_vld;
    always @(*) begin
        case ({i_swp_vld, i_ldm_vld})
            'b10: muxed_wb_rd_vld = i_swp_hold;
            'b01: muxed_wb_rd_vld = i_ldm_mem_vld&i_wb_rd_vld;
            default: muxed_wb_rd_vld = i_wb_rd_vld;
        endcase
    end

    reg [3:0] muxed_wb_rd_code;
    always @(*) begin
        if (i_ldm_vld) begin
            muxed_wb_rd_code = i_ldm_reg_code;
        end
        else begin
            muxed_wb_rd_code = i_wb_rd_code;
        end
    end

    /*
        (shift_result, shift_carry) = Shift_C(i_op1, i_shift_type, i_shift, CPSR.C);
        (alu_result, alu_nzcv) = ALU(shift_result, i_opcode, muxed_op2, (i_nzcv, shift_carry));
    */
    wire [31:0] shift_result;
    wire shift_carry;
    wire [31:0] alu_result;
    wire [3:0] alu_nzcv;
    shift_unit shift_unit_0(
        .i_op       (muxed_op2),
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
        .o_nzcv         (alu_nzcv),
        .o_result       (alu_result)
    );
    reg [3:0] muxed_nzcv_alu;
    always @(*) begin
        case ({i_mul_vld, i_mul_lmode})
            'b10: muxed_nzcv_alu = {i_mul_result_lo[31], i_mul_result_lo=='b0, i_nzcv[1:0]};
            'b11: muxed_nzcv_alu = {i_mul_result_hi[31], {i_mul_result_hi, i_mul_result_lo}=='b0, i_nzcv[1:0]};
            default: muxed_nzcv_alu = alu_nzcv;
        endcase
    end
    assign o_nzcv_alu = alu_nzcv;

    /* to xPSR registers */
    assign o_xpsr_en_ex = i_msr_vld;
    assign o_xpsr_sel = i_mem_addr_src; // Multiplexed mem_addr_src datapath in xpsr_sel
    assign o_xpsr_reg = alu_result;

    /* to registers */
    assign o_rd_en_ex = i_rd_vld&i_mul_result_vld;
    assign o_rd_code_ex = i_rd_code;
    reg [31:0] muxed_rd_reg_ex;
    always @(*) begin
        case ({i_mul_vld, i_mrs_vld})
            'b01: muxed_rd_reg_ex = i_xpsr_reg;
            'b10: muxed_rd_reg_ex = i_mul_result_lo;
            default: muxed_rd_reg_ex = alu_result;
        endcase
    end
    assign o_rd_reg_ex = muxed_rd_reg_ex;
    
    /* to mem ctrl */
    assign o_memctrl_vld = muxed_mem_vld;
    assign o_memctrl_wr = (~muxed_wb_rd_vld);   // STR instruction wrtie register in WB phase
    assign o_memctrl_sign = i_mem_sign;
    assign o_memctrl_size = i_mem_size;
    assign o_memctrl_addr = i_mem_addr_src?alu_result:i_op1;    // P=1:ALU result used as mem address, P=0:op1 used as mem address
    assign o_memctrl_wdata = muxed_op3;

    /* to next pipeline */
    assign o_wb_op = muxed_op3;             // BL instruction write LR register in WB phase, LDM write the same value in register directly
    assign o_wb_rd_src = muxed_mem_vld;     // BL instruction do not enable mem, LDM write the same value in register directly
    assign o_wb_rd_vld = muxed_wb_rd_vld&i_mul_result_vld;
    assign o_wb_rd_code = muxed_wb_rd_code;
    
endmodule