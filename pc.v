module pc (
    input clk,
    input rst_n,
    input en,

    input               i_irq_flag,
    output reg          o_irq_flag,

    /* write PC register input */
    input               i_pc_en,
    input [31:0]        i_pc_reg,
    input               i_pc_irq,

    /* PC register output */
    output [31:0]       o_pc,
    output [31:0]       o_pc_next
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_irq_flag <= 'b0;
        end
        else if(en)begin
            o_irq_flag <= i_irq_flag;
        end
    end

    reg [31:0] pc;
    reg [31:0] pc_next;

    wire [31:0] pc_offset4;
    adder32 adder32_0(
        .i_op1      (pc),
        .i_op2      (32'd4),
        .i_carry    (1'b0),
        .o_result   (pc_offset4),
        .o_carry    ()
    );

    always @(*) begin
        if (i_pc_en) begin
            pc_next = i_pc_reg;
        end
        else begin
            pc_next = pc_offset4;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 32'h0000_0000;
        end
        else if(en)begin
            if (i_pc_irq) begin
                pc <= 32'h0000_0004;
            end
            else begin
                pc <= pc_next;
            end
        end
    end
    
    assign o_pc = pc;
    assign o_pc_next = pc_next;
endmodule