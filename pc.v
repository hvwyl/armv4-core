module pc (
    input clk,
    input rst_n,
    input en,

    /* write PC register input */
    input               i_pc_en,
    input [31:0]        i_pc_reg,

    /* PC register output */
    output [31:0]       o_pc,
    output [31:0]       o_pc_next
);
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
            pc_next <= i_pc_reg;
        end
        else begin
            pc_next <= pc_offset4;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 32'h0000_0000;
        end
        else if(en)begin
            pc <= pc_next;
        end
    end
    
    assign o_pc = pc;
    assign o_pc_next = pc_next;
endmodule