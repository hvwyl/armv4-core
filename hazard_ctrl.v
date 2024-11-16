module hazard_ctrl (
    /* interrupt request input (from ID phase) */
    input i_irq_flag,

    /* write PC signal input */
    input i_pc_en,

    /* WB phase write register signal (from EX phase) */
    input       i_wb_rd_vld,
    input [3:0] i_wb_rd_code,

    /* register code input */
    input [3:0]         i_rm_code,
    input [3:0]         i_rn_code,
    input [3:0]         i_rs_code,
    input               i_rm_code_vld,
    input               i_rn_code_vld,
    input               i_rs_code_vld,

    /* hold input */
    input               i_mul_hold,
    input               i_swp_hold,
    input               i_ldm_hold,

    output o_id_flush,
    output o_ex_flush,
    output o_bubble,
    output o_pipelinehold
);
    wire hazard_data;
    assign hazard_data = i_wb_rd_vld&&(
        (i_rm_code_vld&&(i_rm_code==i_wb_rd_code))||
        (i_rn_code_vld&&(i_rn_code==i_wb_rd_code))||
        (i_rs_code_vld&&(i_rs_code==i_wb_rd_code))
    );

    wire hazard_wb_b;
    assign hazard_wb_b = i_wb_rd_vld&&(i_wb_rd_code==4'b1111);

    wire hazard_b;
    assign hazard_b = i_pc_en;

    assign o_id_flush = hazard_b;
    assign o_ex_flush = hazard_b||hazard_wb_b||hazard_data||i_irq_flag||o_pipelinehold;
    assign o_bubble = hazard_data;
    assign o_pipelinehold = i_mul_hold||i_swp_hold||i_ldm_hold;
endmodule