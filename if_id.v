module if_id (
    input clk,
    input rst_n,
    input en,

    input       i_irq_flag,
    input       i_inst_vld,
    output reg  o_irq_flag,
    output reg  o_inst_vld
    
    /* other signal will generate by instruction rom */
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_irq_flag <= 1'b0;
            o_inst_vld <= 1'b0;
        end
        else if (en) begin
            o_irq_flag <= i_irq_flag;
            o_inst_vld <= i_inst_vld;
        end
    end
endmodule