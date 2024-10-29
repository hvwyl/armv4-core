module armv4core (
    input clk,
    input rst_n,
    input en,

    /* interrupt request */
    input           i_irq,
    input [31:0]    i_irq_r0,
    input [31:0]    i_irq_r1,

    /* rom bus */
    output          o_rom_en,
    output [31:0]   o_rom_addr,
    input [31:0]    i_rom_data,

    /* ram bus */
    output          o_ram_en,
    output          o_ram_wr,
    output [1:0]    o_ram_size,
    output [31:0]   o_ram_addr,
    input [31:0]    i_ram_rdata,
    output [31:0]   o_ram_wdata
);
    wire            irq_flag                ;
    wire            pc_en                   ;
    wire [31:0]     pc_reg                  ;
    wire [31:0]     pc                      ;
    wire [31:0]     pc_next                 ;
    wire            int_mode                ;
    wire            irq_mask                ;
    wire [3:0]      nzcv                    ;
    wire [3:0]      nzcv_alu                ;
    wire [3:0]      nzcv_next               ;
    wire            xpsr_en_ex              ;
    wire            xpsr_sel                ;
    wire [31:0]     xpsr_reg_msr            ;
    wire [31:0]     xpsr_reg_mrs            ;
    wire [3:0]      rm_code                 ;
    wire [3:0]      rn_code                 ;
    wire [3:0]      rs_code                 ;
    wire [3:0]      re_code                 ;
    wire            rm_code_vld             ;
    wire            rn_code_vld             ;
    wire            rs_code_vld             ;
    wire [31:0]     rm_reg                  ;
    wire [31:0]     rn_reg                  ;
    wire [31:0]     rs_reg                  ;
    wire [31:0]     re_reg                  ;
    wire [31:0]     rm_reg_forwarded        ;
    wire [31:0]     rn_reg_forwarded        ;
    wire [31:0]     rs_reg_forwarded        ;
    wire [31:0]     re_reg_forwarded        ;

    wire            hazard_id_flush         ;
    wire            hazard_ex_flush         ;
    wire            hazard_bubble           ;
    wire            hazard_irq_ctrlhold     ;
    wire            hazard_pipelinehold     ;

    wire            if_irq_flag             ;

    wire [31:0]     inst                    ;
    wire            inst_vld                ;

    wire            id_irq_flag             ;
    wire [31:0]     id_op1                  ;
    wire [31:0]     id_op2                  ;
    wire [7:0]      id_shift                ;
    wire [2:0]      id_shift_type           ;
    wire [31:0]     id_op3                  ;
    wire [3:0]      id_opcode               ;
    wire            id_mem_vld              ;
    wire [1:0]      id_mem_size             ;
    wire            id_mem_sign             ;
    wire            id_mem_addr_src         ;
    wire            id_rd_vld               ;
    wire [3:0]      id_rd_code              ;
    wire            id_wb_rd_vld            ;
    wire [3:0]      id_wb_rd_code           ;
    wire            id_nzcv_flag            ;
    wire            id_swp_vld              ;
    wire            id_ldm_vld              ;
    wire            id_mrs_vld              ;
    wire            id_msr_vld              ;
    wire            id_ldm_p                ;
    wire            id_ldm_u                ;
    wire            id_ldm_s                ;
    wire            id_ldm_l                ;
    wire [15:0]     id_ldm_reglist          ;

    wire            ex_irq_flag             ;
    wire [31:0]     ex_op1                  ;
    wire [31:0]     ex_op2                  ;
    wire [7:0]      ex_shift                ;
    wire [2:0]      ex_shift_type           ;
    wire [31:0]     ex_op3                  ;
    wire [3:0]      ex_opcode               ;
    wire            ex_mem_vld              ;
    wire [1:0]      ex_mem_size             ;
    wire            ex_mem_sign             ;
    wire            ex_mem_addr_src         ;
    wire            ex_rd_vld               ;
    wire [3:0]      ex_rd_code              ;
    wire            ex_wb_rd_vld            ;
    wire [3:0]      ex_wb_rd_code           ;
    wire            ex_nzcv_flag            ;
    wire            ex_swp_vld              ;
    wire            ex_ldm_vld              ;
    wire            ex_mrs_vld              ;
    wire            ex_msr_vld              ;

    wire            memctrl_vld             ;
    wire            memctrl_wr              ;
    wire            memctrl_sign            ;
    wire [1:0]      memctrl_size            ;
    wire [31:0]     memctrl_addr            ;
    wire [31:0]     memctrl_wdata           ;
    wire [31:0]     memctrl_rdata           ;

    wire [31:0]     ex_next_wb_op       ;
    wire            ex_next_wb_rd_src   ;
    wire            ex_next_wb_rd_vld   ;
    wire [3:0]      ex_next_wb_rd_code  ;

    wire [31:0]     wb_op               ;
    wire            wb_rd_src           ;
    wire            wb_rd_vld           ;
    wire [3:0]      wb_rd_code          ;

    wire            rd_en_ex            ;
    wire [3:0]      rd_code_ex          ;
    wire [31:0]     rd_reg_ex           ;

    wire            rd_en_wb            ;
    wire [3:0]      rd_code_wb          ;
    wire [31:0]     rd_reg_wb           ;
    
    wire            swp_hold            ;
    wire            spsr_res            ;
    wire            ldm_hold            ;
    wire            ldm_flushreq        ;
    wire [31:0]     ldm_offset          ;
    wire            ldm_mem_vld         ;

    irq_ctrl irq_ctrl_0(
        .clk                (clk                                        ),
        .rst_n              (rst_n                                      ),
        .en                 (en                                         ),
        .i_irq              (i_irq                                      ),
        .i_irq_mask         (irq_mask                                   ),
        .i_irq_res          (ex_irq_flag&(~hazard_irq_ctrlhold)         ),
        .o_irq_flag         (irq_flag                                   )
    );
    pc pc_0(
        .clk                (clk                                        ),
        .rst_n              (rst_n                                      ),
        .en                 (en&(~hazard_bubble)&(~hazard_pipelinehold) ),

        .i_irq_flag         (irq_flag                                   ),
        .o_irq_flag         (if_irq_flag                                ),

        .i_pc_en            (pc_en                                      ),
        .i_pc_reg           (pc_reg                                     ),
        .i_pc_irq           (irq_flag&ex_irq_flag                       ),
        .o_pc               (pc                                         ),
        .o_pc_next          (pc_next                                    )
    );
    registers registers_0(
        .clk                (clk                                        ),
        .rst_n              (rst_n                                      ),
        .en                 (en                                         ),

        .i_int_mode         (int_mode                                   ),

        .i_irq_bak          ({irq_flag, if_irq_flag}                    ),
        .i_irq_r0           (i_irq_r0                                   ),
        .i_irq_r1           (i_irq_r1                                   ),

        .i_rm_code          (rm_code                                    ),
        .i_rn_code          (rn_code                                    ),
        .i_rs_code          (rs_code                                    ),
        .i_re_code          (re_code                                    ),

        .o_rm_reg           (rm_reg                                     ),
        .o_rn_reg           (rn_reg                                     ),
        .o_rs_reg           (rs_reg                                     ),
        .o_re_reg           (re_reg                                     ),

        .o_pc_en            (pc_en                                      ),
        .o_pc_reg           (pc_reg                                     ),

        .i_pc_next          (pc_next                                    ),

        .i_rd_en_ex         (rd_en_ex                                   ),
        .i_rd_code_ex       (rd_code_ex                                 ),
        .i_rd_reg_ex        (rd_reg_ex                                  ),

        .i_rd_en_wb         (rd_en_wb                                   ),
        .i_rd_code_wb       (rd_code_wb                                 ),
        .i_rd_reg_wb        (rd_reg_wb                                  )
    );
    cpsr cpsr_0(
        .clk                (clk                                        ),
        .rst_n              (rst_n                                      ),
        .en                 (en&(~hazard_pipelinehold)                  ),

        .i_spsr_bak         (irq_flag&ex_irq_flag                       ),
        .i_spsr_res         (spsr_res                                   ),

        .o_int_mode         (int_mode                                   ),

        .o_irq_mask         (irq_mask                                   ),

        .i_nzcv_flag        (ex_nzcv_flag                               ),
        .i_nzcv_alu         (nzcv_alu                                   ),

        .o_nzcv             (nzcv                                       ),
        .o_nzcv_next        (nzcv_next                                  ),
        .i_xpsr_en_ex       (xpsr_en_ex                                 ),
        .i_xpsr_sel         (xpsr_sel                                   ),
        .i_xpsr_reg         (xpsr_reg_msr                               ),
        .o_xpsr_reg         (xpsr_reg_mrs                               )
    );
    forward_ctrl forward_ctrl_0(
        .i_rd_en_ex         (rd_en_ex                                   ),
        .i_rd_code_ex       (rd_code_ex                                 ),
        .i_rd_reg_ex        (rd_reg_ex                                  ),

        .i_rd_en_wb         (rd_en_wb                                   ),
        .i_rd_code_wb       (rd_code_wb                                 ),
        .i_rd_reg_wb        (rd_reg_wb                                  ),

        .i_rm_code          (rm_code                                    ),
        .i_rn_code          (rn_code                                    ),
        .i_rs_code          (rs_code                                    ),

        .i_rm_reg           (rm_reg                                     ),
        .i_rn_reg           (rn_reg                                     ),
        .i_rs_reg           (rs_reg                                     ),

        .o_rm_reg           (rm_reg_forwarded                           ),
        .o_rn_reg           (rn_reg_forwarded                           ),
        .o_rs_reg           (rs_reg_forwarded                           ),

        .i_re_code          (re_code                                    ),

        .i_re_reg           (re_reg                                     ),

        .o_re_reg           (re_reg_forwarded                           )
    );
    hazard_ctrl hazard_ctrl_0(
        .i_irq_flag         (id_irq_flag                                ),

        .i_pc_en            (pc_en                                      ),

        .i_wb_rd_vld        (ex_next_wb_rd_vld                          ),
        .i_wb_rd_code       (ex_next_wb_rd_code                         ),

        .i_rm_code          (rm_code                                    ),
        .i_rn_code          (rn_code                                    ),
        .i_rs_code          (rs_code                                    ),
        .i_rm_code_vld      (rm_code_vld                                ),
        .i_rn_code_vld      (rn_code_vld                                ),
        .i_rs_code_vld      (rs_code_vld                                ),

        .i_swp_hold         (swp_hold                                   ),
        .i_ldm_hold         (ldm_hold                                   ),

        .o_id_flush         (hazard_id_flush                            ),
        .o_ex_flush         (hazard_ex_flush                            ),
        .o_bubble           (hazard_bubble                              ),
        .o_irq_ctrlhold     (hazard_irq_ctrlhold                        ),
        .o_pipelinehold     (hazard_pipelinehold                        )
    );
    if_id if_id_0(
        .clk                (clk                                        ),
        .rst_n              (rst_n                                      ),
        .en                 (en&(~hazard_bubble)&(~hazard_pipelinehold) ),

        .i_irq_flag         (if_irq_flag&irq_flag                       ),
        .i_inst_vld         (~(hazard_id_flush)                         ),
        .o_irq_flag         (id_irq_flag                                ),
        .o_inst_vld         (inst_vld                                   )
    );
    assign o_rom_en = en&(~hazard_bubble)&(~hazard_pipelinehold);
    assign o_rom_addr = pc;
    assign inst = i_rom_data;
    id_stage id_stage_0(
        .i_inst_vld         (inst_vld&(~hazard_ex_flush)&(~ldm_flushreq)),
        .i_inst             (inst                                       ),
 
        .i_nzcv_next        (nzcv_next                                  ),
 
        .i_pc               (pc                                         ),
 
        .o_rm_code          (rm_code                                    ),
        .o_rn_code          (rn_code                                    ),
        .o_rs_code          (rs_code                                    ),
        .o_rm_code_vld      (rm_code_vld                                ),
        .o_rn_code_vld      (rn_code_vld                                ),
        .o_rs_code_vld      (rs_code_vld                                ),

        .i_rm_reg           (rm_reg_forwarded                           ),
        .i_rn_reg           (rn_reg_forwarded                           ),
        .i_rs_reg           (rs_reg_forwarded                           ),

        .o_op1              (id_op1                                     ),
        .o_op2              (id_op2                                     ),
        .o_shift            (id_shift                                   ),
        .o_shift_type       (id_shift_type                              ),
        .o_op3              (id_op3                                     ),
        .o_opcode           (id_opcode                                  ),
        .o_mem_vld          (id_mem_vld                                 ),
        .o_mem_size         (id_mem_size                                ),
        .o_mem_sign         (id_mem_sign                                ),
        .o_mem_addr_src     (id_mem_addr_src                            ),
        .o_rd_vld           (id_rd_vld                                  ),
        .o_rd_code          (id_rd_code                                 ),
        .o_wb_rd_vld        (id_wb_rd_vld                               ),
        .o_wb_rd_code       (id_wb_rd_code                              ),
        .o_nzcv_flag        (id_nzcv_flag                               ),
        .o_swp_vld          (id_swp_vld                                 ),
        .o_ldm_vld          (id_ldm_vld                                 ),
        .o_mrs_vld          (id_mrs_vld                                 ),
        .o_msr_vld          (id_msr_vld                                 ),

        .o_ldm_p            (id_ldm_p                                   ),
        .o_ldm_u            (id_ldm_u                                   ),
        .o_ldm_s            (id_ldm_s                                   ),
        .o_ldm_l            (id_ldm_l                                   ),
        .o_ldm_reglist      (id_ldm_reglist                             )
    );
    id_ex id_ex_0(
        .clk                (clk                                        ),
        .rst_n              (rst_n                                      ),
        .en                 (en&(~hazard_pipelinehold)                  ),

        .i_irq_flag         (irq_flag&id_irq_flag                       ),
        .i_op1              (id_op1                                     ),
        .i_op2              (id_op2                                     ),
        .i_shift            (id_shift                                   ),
        .i_shift_type       (id_shift_type                              ),
        .i_op3              (id_op3                                     ),
        .i_opcode           (id_opcode                                  ),
        .i_mem_vld          (id_mem_vld                                 ),
        .i_mem_size         (id_mem_size                                ),
        .i_mem_sign         (id_mem_sign                                ),
        .i_mem_addr_src     (id_mem_addr_src                            ),
        .i_rd_vld           (id_rd_vld                                  ),
        .i_rd_code          (id_rd_code                                 ),
        .i_wb_rd_vld        (id_wb_rd_vld                               ),
        .i_wb_rd_code       (id_wb_rd_code                              ),
        .i_nzcv_flag        (id_nzcv_flag                               ),
        .i_swp_vld          (id_swp_vld                                 ),
        .i_ldm_vld          (id_ldm_vld                                 ),
        .i_mrs_vld          (id_mrs_vld                                 ),
        .i_msr_vld          (id_msr_vld                                 ),

        .o_irq_flag         (ex_irq_flag                                ),
        .o_op1              (ex_op1                                     ),
        .o_op2              (ex_op2                                     ),
        .o_shift            (ex_shift                                   ),
        .o_shift_type       (ex_shift_type                              ),
        .o_op3              (ex_op3                                     ),
        .o_opcode           (ex_opcode                                  ),
        .o_mem_vld          (ex_mem_vld                                 ),
        .o_mem_size         (ex_mem_size                                ),
        .o_mem_sign         (ex_mem_sign                                ),
        .o_mem_addr_src     (ex_mem_addr_src                            ),
        .o_rd_vld           (ex_rd_vld                                  ),
        .o_rd_code          (ex_rd_code                                 ),
        .o_wb_rd_vld        (ex_wb_rd_vld                               ),
        .o_wb_rd_code       (ex_wb_rd_code                              ),
        .o_nzcv_flag        (ex_nzcv_flag                               ),
        .o_swp_vld          (ex_swp_vld                                 ),
        .o_ldm_vld          (ex_ldm_vld                                 ),
        .o_mrs_vld          (ex_mrs_vld                                 ),
        .o_msr_vld          (ex_msr_vld                                 )
    );
    swp_ctrl swp_ctrl_0(
        .clk                (clk                                        ),
        .rst_n              (rst_n                                      ),
        .en                 (en                                         ),
        .i_swp_vld          (id_swp_vld                                 ),
        .o_swp_hold         (swp_hold                                   )
    );
    ldm_ctrl ldm_ctrl_0(
        .clk                (clk                                        ),
        .rst_n              (rst_n                                      ),
        .en                 (en                                         ),

        .i_ldm_vld          (id_ldm_vld                                 ),
        .i_ldm_p            (id_ldm_p                                   ),
        .i_ldm_u            (id_ldm_u                                   ),
        .i_ldm_s            (id_ldm_s                                   ),
        .i_ldm_l            (id_ldm_l                                   ),
        .i_reglist          (id_ldm_reglist                             ),

        .o_spsr_res         (spsr_res                                    ),

        .o_ldm_hold         (ldm_hold                                   ),
        .o_ldm_flushreq     (ldm_flushreq                               ),
        .o_ldm_offset       (ldm_offset                                 ),
        .o_ldm_mem_vld      (ldm_mem_vld                                ),
        .o_ldm_reg_code     (re_code                                    )
    );
    ex_stage ex_stage_0(
        .i_nzcv             (nzcv                                       ),
        .o_nzcv_alu         (nzcv_alu                                   ),

        .o_xpsr_en_ex       (xpsr_en_ex                                 ),
        .o_xpsr_sel         (xpsr_sel                                   ),
        .o_xpsr_reg         (xpsr_reg_msr                               ),
        .i_xpsr_reg         (xpsr_reg_mrs                               ),

        .o_rd_en_ex         (rd_en_ex                                   ),
        .o_rd_code_ex       (rd_code_ex                                 ),
        .o_rd_reg_ex        (rd_reg_ex                                  ),

        .o_memctrl_vld      (memctrl_vld                                ),
        .o_memctrl_wr       (memctrl_wr                                 ),
        .o_memctrl_sign     (memctrl_sign                               ),
        .o_memctrl_size     (memctrl_size                               ),
        .o_memctrl_addr     (memctrl_addr                               ),
        .o_memctrl_wdata    (memctrl_wdata                              ),

        .i_op1              (ex_op1                                     ),
        .i_op2              (ex_op2                                     ),
        .i_shift            (ex_shift                                   ),
        .i_shift_type       (ex_shift_type                              ),
        .i_op3              (ex_op3                                     ),
        .i_opcode           (ex_opcode                                  ),
        .i_mem_vld          (ex_mem_vld                                 ),
        .i_mem_size         (ex_mem_size                                ),
        .i_mem_sign         (ex_mem_sign                                ),
        .i_mem_addr_src     (ex_mem_addr_src                            ),
        .i_rd_vld           (ex_rd_vld                                  ),
        .i_rd_code          (ex_rd_code                                 ),
        .i_wb_rd_vld        (ex_wb_rd_vld                               ),
        .i_wb_rd_code       (ex_wb_rd_code                              ),

        .i_swp_hold         (swp_hold                                   ),

        .i_ldm_offset       (ldm_offset                                 ),
        .i_ldm_mem_vld      (ldm_mem_vld                                ),
        .i_ldm_reg_code     (re_code                                    ),
        .i_ldm_reg          (re_reg_forwarded                           ),

        .i_swp_vld          (ex_swp_vld                                 ),
        .i_ldm_vld          (ex_ldm_vld                                 ),
        .i_mrs_vld          (ex_mrs_vld                                 ),
        .i_msr_vld          (ex_msr_vld                                 ),
    
        .o_wb_op            (ex_next_wb_op                              ),
        .o_wb_rd_src        (ex_next_wb_rd_src                          ),
        .o_wb_rd_vld        (ex_next_wb_rd_vld                          ),
        .o_wb_rd_code       (ex_next_wb_rd_code                         )
    );
    memctrl memctrl_0(
        .clk                (clk                                        ),
        .rst_n              (rst_n                                      ),
        .en                 (en                                         ),

        .i_memctrl_vld      (memctrl_vld                                ),
        .i_memctrl_wr       (memctrl_wr                                 ),
        .i_memctrl_sign     (memctrl_sign                               ),
        .i_memctrl_size     (memctrl_size                               ),
        .i_memctrl_addr     (memctrl_addr                               ),
        .o_memctrl_rdata    (memctrl_rdata                              ),
        .i_memctrl_wdata    (memctrl_wdata                              ),

        .o_ram_en           (o_ram_en                                   ),
        .o_ram_wr           (o_ram_wr                                   ),
        .o_ram_size         (o_ram_size                                 ),
        .o_ram_addr         (o_ram_addr                                 ),
        .i_ram_rdata        (i_ram_rdata                                ),
        .o_ram_wdata        (o_ram_wdata                                )
    );
    ex_wb ex_wb_0(
        .clk                (clk                                        ),
        .rst_n              (rst_n                                      ),
        .en                 (en                                         ),
    
        .i_wb_op            (ex_next_wb_op                              ),
        .i_wb_rd_src        (ex_next_wb_rd_src                          ),
        .i_wb_rd_vld        (ex_next_wb_rd_vld                          ),
        .i_wb_rd_code       (ex_next_wb_rd_code                         ),

        .o_wb_op            (wb_op                                      ),
        .o_wb_rd_src        (wb_rd_src                                  ),
        .o_wb_rd_vld        (wb_rd_vld                                  ),
        .o_wb_rd_code       (wb_rd_code                                 )
    );
    wb_stage wb_stage_0(
        .i_wb_op            (wb_op                                      ),
        .i_wb_rd_src        (wb_rd_src                                  ),
        .i_wb_rd_vld        (wb_rd_vld                                  ),
        .i_wb_rd_code       (wb_rd_code                                 ),

        .i_memctrl_rdata    (memctrl_rdata                              ),

        .o_rd_en_wb         (rd_en_wb                                   ),
        .o_rd_code_wb       (rd_code_wb                                 ),
        .o_rd_reg_wb        (rd_reg_wb                                  )
    );
endmodule