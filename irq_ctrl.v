module irq_ctrl (
    input clk,
    input rst_n,
    input en,

    input   i_irq,
    input   i_irq_mask,

    input   i_irq_res,

    output  o_irq_flag
);
    reg irq_flag;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            irq_flag <= 'b0;
        end
        else if (en) begin
            if (!irq_flag) begin
                if ((!i_irq_mask) && i_irq) begin
                    irq_flag <= 'b1;
                end
                else begin
                    irq_flag <= 'b0;
                end
            end
            else begin
                if (i_irq_res) begin
                    irq_flag <= 'b0;
                end
                else begin
                    irq_flag <= 'b1;
                end
            end
        end
    end
    assign o_irq_flag = irq_flag;
endmodule