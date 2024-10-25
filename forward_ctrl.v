module forward_ctrl (
    /* EX phase write register */
    input               i_rd_en_ex,
    input [3:0]         i_rd_code_ex,
    input [31:0]        i_rd_reg_ex,

    /* WB phase write register */
    input               i_rd_en_wb,
    input [3:0]         i_rd_code_wb,
    input [31:0]        i_rd_reg_wb,

    /* register code input */
    input [3:0]         i_rm_code,
    input [3:0]         i_rn_code,
    input [3:0]         i_rs_code,

    /* register input */
    input [31:0]        i_rm_reg,
    input [31:0]        i_rn_reg,
    input [31:0]        i_rs_reg,

    /* register output */
    output reg [31:0]   o_rm_reg,
    output reg [31:0]   o_rn_reg,
    output reg [31:0]   o_rs_reg,

    /* register code input (from EX phase) */
    input [3:0]         i_re_code,

    /* register input (from EX phase) */
    input [31:0]        i_re_reg,

    /* register output (from EX phase) */
    output reg [31:0]   o_re_reg
);
    /*
        forward ctrl
        2'b00: no bypass
        2'b01: bypass the value of the WB phase
        2'b10: bypass the value of the EX phase
        2'b11: write registers in parallel, bypass the value of the EX phase
    */
    always @(*) begin
        case ({i_rd_en_ex & (i_rd_code_ex == i_rm_code), i_rd_en_wb & (i_rd_code_wb == i_rm_code)})
            2'b00: o_rm_reg = i_rm_reg;
            2'b01: o_rm_reg = i_rd_reg_wb;
            2'b10: o_rm_reg = i_rd_reg_ex;
            2'b11: o_rm_reg = i_rd_reg_ex;
        endcase
        case ({i_rd_en_ex & (i_rd_code_ex == i_rn_code), i_rd_en_wb & (i_rd_code_wb == i_rn_code)})
            2'b00: o_rn_reg = i_rn_reg;
            2'b01: o_rn_reg = i_rd_reg_wb;
            2'b10: o_rn_reg = i_rd_reg_ex;
            2'b11: o_rn_reg = i_rd_reg_ex;
        endcase
        case ({i_rd_en_ex & (i_rd_code_ex == i_rs_code), i_rd_en_wb & (i_rd_code_wb == i_rs_code)})
            2'b00: o_rs_reg = i_rs_reg;
            2'b01: o_rs_reg = i_rd_reg_wb;
            2'b10: o_rs_reg = i_rd_reg_ex;
            2'b11: o_rs_reg = i_rd_reg_ex;
        endcase
    end
    /*
        EX phase: bypass the value of the WB phase
    */
    always @(*) begin
        if (i_rd_en_wb & (i_rd_code_wb == i_re_code)) begin
            o_re_reg = i_rd_reg_wb;
        end
        else begin
            o_re_reg = i_re_reg;
        end
    end
endmodule