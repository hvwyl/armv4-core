module registers (
    input clk,
    input rst_n,
    input en,

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
    wire [31:0] reg_output [15:0];
    
    genvar i;
    generate
        for (i = 0; i<15; i=i+1) begin
            assign reg_output[i] = reg_stack[i];
        end
        assign reg_output[15] = i_pc_next;
    endgenerate

    assign o_rm_reg = reg_output[i_rm_code];
    assign o_rn_reg = reg_output[i_rn_code];
    assign o_rs_reg = reg_output[i_rs_code];
    assign o_re_reg = reg_output[i_re_code];

    wire rd_en_ex, rd_en_wb;
    wire pc_en_ex, pc_en_wb;
    assign rd_en_ex = (i_rd_code_ex != 4'b1111)&i_rd_en_ex;
    assign rd_en_wb = (i_rd_code_wb != 4'b1111)&i_rd_en_wb;
    assign pc_en_ex = (i_rd_code_ex == 4'b1111)&i_rd_en_ex;
    assign pc_en_wb = (i_rd_code_wb == 4'b1111)&i_rd_en_wb;
    
    assign o_pc_en = pc_en_ex|pc_en_wb;
    assign o_pc_reg = pc_en_wb?(i_rd_reg_wb):(i_rd_reg_ex);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_stack[0] <= 'b0;
            reg_stack[1] <= 'b0;
            reg_stack[2] <= 'b0;
            reg_stack[3] <= 'b0;
            reg_stack[4] <= 'b0;
            reg_stack[5] <= 'b0;
            reg_stack[6] <= 'b0;
            reg_stack[7] <= 'b0;
            reg_stack[8] <= 'b0;
            reg_stack[9] <= 'b0;
            reg_stack[10] <= 'b0;
            reg_stack[11] <= 'b0;
            reg_stack[12] <= 'b0;
            reg_stack[13] <= 'b0;
            reg_stack[14] <= 'b0;
        end
        else begin
            if (en) begin
                if (rd_en_ex && rd_en_wb && (i_rd_code_ex == i_rd_code_wb)) begin
                    // write the same registers in parallel, use the value of the EX phase
                    reg_stack[i_rd_code_ex] <= i_rd_reg_ex;
                end
                else begin
                    if (rd_en_ex) begin
                        reg_stack[i_rd_code_ex] <= i_rd_reg_ex;
                    end
                    if (rd_en_wb) begin
                        reg_stack[i_rd_code_wb] <= i_rd_reg_wb;
                    end
                end
            end
        end
    end
endmodule
