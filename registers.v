module registers (
    input clk,
    input rst_n,
    input en,

    /* interrupt mode input */
    input               i_int_mode,

    /* interrupt request backup input*/
    input [1:0]         i_irq_bak,
    input [31:0]        i_irq_r0,

    /* register code input */
    input [3:0] i_rm_code,
    input [3:0] i_rn_code,
    input [3:0] i_rs_code,
    input [3:0] i_re_code,

    /* register output */
    output [31:0] o_rm_reg,
    output [31:0] o_rn_reg,
    output [31:0] o_rs_reg,
    output [31:0] o_re_reg,

    /* write PC register output */
    output              o_pc_en,
    output [31:0]       o_pc_reg,

    /* PC next input */
    input [31:0]        i_pc_next,

    /* EX phase write register input */
    input               i_rd_en_ex,
    input [3:0]         i_rd_code_ex,
    input [31:0]        i_rd_reg_ex,

    /* WB phase write register input */
    input               i_rd_en_wb,
    input [3:0]         i_rd_code_wb,
    input [31:0]        i_rd_reg_wb
);
    reg [31:0] reg_stack [14:0];
    reg [31:0] reg_stack_int [14:0];
    wire [31:0] reg_output [15:0];
    
    genvar i;
    generate
        for (i = 0; i<15; i=i+1) begin
            assign reg_output[i] = (!i_int_mode)?reg_stack[i]:reg_stack_int[i];
        end
        assign reg_output[15] = i_pc_next;
    endgenerate

    assign o_rm_reg = reg_output[i_rm_code];
    assign o_rn_reg = reg_output[i_rn_code];
    assign o_rs_reg = reg_output[i_rs_code];
    assign o_re_reg = reg_output[i_re_code];

    wire pc_en_ex, pc_en_wb;
    assign pc_en_ex = (i_rd_code_ex == 4'b1111)&i_rd_en_ex;
    assign pc_en_wb = (i_rd_code_wb == 4'b1111)&i_rd_en_wb;
    assign o_pc_en = pc_en_ex|pc_en_wb;
    assign o_pc_reg = pc_en_wb?(i_rd_reg_wb):(i_rd_reg_ex);

    reg [31:0] reg_next [14:0];
    generate
        for (i = 0; i<15; i=i+1) begin
            always @(*) begin
                case ({(i_rd_code_ex == i)&i_rd_en_ex, (i_rd_code_wb == i)&i_rd_en_wb})
                    2'b00: if (!i_int_mode) begin
                        reg_next[i] = reg_stack[i];
                    end
                    else begin
                        reg_next[i] = reg_stack_int[i];
                    end
                    2'b01: reg_next[i] = i_rd_reg_wb;
                    2'b10: reg_next[i] = i_rd_reg_ex;
                    // write the same registers in parallel, use the value of the EX phase
                    2'b11: reg_next[i] = i_rd_reg_ex;
                endcase
            end
            if (0 == i) begin
                always @(posedge clk or negedge rst_n) begin
                    if (!rst_n) begin
                        reg_stack[i] <= 'b0;
                        reg_stack_int[i] <= 'b0;
                    end
                    else begin
                        if (en) begin
                            if (!i_int_mode) begin
                                reg_stack[i] <= reg_next[i];
                                case (i_irq_bak)
                                    2'b00, 2'b01: reg_stack_int[i] <= i_irq_r0;
                                    default: reg_stack_int[i] <= reg_stack_int[i];
                                endcase
                            end
                            else begin
                                reg_stack_int[i] <= reg_next[i];
                            end
                        end
                    end
                end
            end
            else if (13 == i) begin
                always @(posedge clk or negedge rst_n) begin
                    if (!rst_n) begin
                        reg_stack[i] <= 'b0;
                        reg_stack_int[i] <= 'b0;
                    end
                    else begin
                        if (en) begin
                            if (!i_int_mode) begin
                                reg_stack[i] <= reg_next[i];
                                case (i_irq_bak)
                                    2'b10, 2'b11: reg_stack_int[13] <= reg_next[13];
                                    default: reg_stack_int[13] <= reg_stack_int[13];
                                endcase
                            end
                            else begin
                                reg_stack_int[i] <= reg_next[i];
                            end
                        end
                    end
                end
            end
            else if (14 == i) begin
                always @(posedge clk or negedge rst_n) begin
                    if (!rst_n) begin
                        reg_stack[i] <= 'b0;
                        reg_stack_int[i] <= 'b0;
                    end
                    else begin
                        if (en) begin
                            if (!i_int_mode) begin
                                reg_stack[i] <= reg_next[i];
                                case (i_irq_bak)
                                    2'b10: begin
                                        reg_stack_int[14] <= i_pc_next;
                                    end
                                    2'b11: begin
                                        if (o_pc_en) begin
                                            reg_stack_int[14] <= o_pc_reg;
                                        end
                                    end
                                    default: reg_stack_int[14] <= reg_stack_int[14];
                                endcase
                            end
                            else begin
                                reg_stack_int[i] <= reg_next[i];
                            end
                        end
                    end
                end
            end
            else begin
                always @(posedge clk or negedge rst_n) begin
                    if (!rst_n) begin
                        reg_stack[i] <= 'b0;
                        reg_stack_int[i] <= 'b0;
                    end
                    else begin
                        if (en) begin
                            if (!i_int_mode) begin
                                reg_stack[i] <= reg_next[i];
                            end
                            else begin
                                reg_stack_int[i] <= reg_next[i];
                            end
                        end
                    end
                end
            end
        end
    endgenerate
endmodule
