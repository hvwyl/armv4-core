module ex_mux (
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

    output [31:0]       o_op1,
    output reg [31:0]   o_op2,
    output [7:0]        o_shift,
    output [2:0]        o_shift_type,
    output reg [31:0]   o_op3,
    output [3:0]        o_opcode,
    output reg          o_mem_vld,
    output [1:0]        o_mem_size,
    output              o_mem_sign,
    output              o_mem_addr_src,
    output              o_rd_vld,
    output [3:0]        o_rd_code,
    output reg          o_wb_rd_vld,
    output reg [3:0]    o_wb_rd_code,

    /* high-priority function control signals */
    input               i_swp_vld,       // SWP instruction
    input               i_ldm_vld,       // LDM instruction

    /* from swp ctrl */
    input               i_swp_hold,

    /* from ldm ctrl */
    input [31:0]        i_ldm_offset,
    input               i_ldm_mem_vld,
    input [3:0]         i_ldm_reg_code,
    input [31:0]        i_ldm_reg
);
    assign o_op1            =   i_op1           ;
    always @(*) begin
        if (i_ldm_vld) begin
            o_op2           =   i_ldm_offset    ;
        end
        else begin
            o_op2           =   i_op2           ;
        end
    end
    assign o_shift          =   i_shift         ;
    assign o_shift_type     =   i_shift_type    ;
    always @(*) begin
        if (i_ldm_vld) begin
            o_op3           =   i_ldm_reg       ;
        end
        else begin
            o_op3           =   i_op3           ;
        end
    end
    assign o_opcode         =   i_opcode        ;

    always @(*) begin
        if (i_ldm_vld) begin
            o_mem_vld       =   i_ldm_mem_vld   ;
        end
        else begin
            o_mem_vld       =   i_mem_vld       ;
        end
    end
    assign o_mem_size       =   i_mem_size      ;
    assign o_mem_sign       =   i_mem_sign      ;
    assign o_mem_addr_src   =   i_mem_addr_src  ;
    assign o_rd_vld         =   i_rd_vld        ;
    assign o_rd_code        =   i_rd_code       ;
    always @(*) begin
        case ({i_swp_vld, i_ldm_vld})
            'b10: o_wb_rd_vld = i_swp_hold;
            'b01: o_wb_rd_vld = i_ldm_mem_vld&i_wb_rd_vld;
            default: o_wb_rd_vld = i_wb_rd_vld;
        endcase
    end
    always @(*) begin
        if (i_ldm_vld) begin
            o_wb_rd_code    =   i_ldm_reg_code  ;
        end
        else begin
            o_wb_rd_code    =   i_wb_rd_code    ;
        end
    end

endmodule