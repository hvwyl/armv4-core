`include "def.v"
module alu (
    input [3:0]         i_opcode,
    input [3:0]         i_nzcv,
    input [31:0]        i_op1,
    input [31:0]        i_op2,
    input               i_shift_carry,  // from shift_unit
    output reg [3:0]    o_nzcv,
    output reg [31:0]   o_result
);
    // adc module
    reg [31:0] adc_unit_op1, adc_unit_op2;
    reg adc_unit_carryin;
    wire [31:0] adc_unit_result;
    wire adc_unit_carryout, adc_unit_overflowout;
    adder32 adder32_0(
        .i_op1      (adc_unit_op1),
        .i_op2      (adc_unit_op2),
        .i_carry    (adc_unit_carryin),

        .o_result   (adc_unit_result),
        .o_carry    (adc_unit_carryout)
    );
    assign adc_unit_overflowout = ({adc_unit_op1[31], adc_unit_op2[31], adc_unit_result[31]}==3'b110)|({adc_unit_op1[31], adc_unit_op2[31], adc_unit_result[31]}==3'b001);

    always @(*) begin
        case (i_opcode)
            `ALU_SUB, `ALU_CMP: begin
                adc_unit_op1 = i_op1;
                adc_unit_op2 = ~i_op2;
                adc_unit_carryin = 'b1;
            end
            `ALU_RSB: begin
                adc_unit_op1 = ~i_op1;
                adc_unit_op2 = i_op2;
                adc_unit_carryin = 'b1;
            end
            `ALU_ADD, `ALU_CMN: begin
                adc_unit_op1 = i_op1;
                adc_unit_op2 = i_op2;
                adc_unit_carryin = 'b0;
            end
            `ALU_ADC: begin
                adc_unit_op1 = i_op1;
                adc_unit_op2 = i_op2;
                adc_unit_carryin = i_nzcv[1];
            end
            `ALU_SBC: begin
                adc_unit_op1 = i_op1;
                adc_unit_op2 = ~i_op2;
                adc_unit_carryin = i_nzcv[1];
            end
            `ALU_RSC: begin
                adc_unit_op1 = ~i_op1;
                adc_unit_op2 = i_op2;
                adc_unit_carryin = i_nzcv[1];
            end
            default: begin
                adc_unit_op1 = 'b0;
                adc_unit_op2 = 'b0;
                adc_unit_carryin = 'b0;
            end
        endcase
    end

    // o_result and o_nzcv
    always @(*) begin
        case (i_opcode)
            `ALU_AND, `ALU_TST: begin
                o_result = i_op1 & i_op2;
            end
            `ALU_EOR, `ALU_TEQ: begin
                o_result = i_op1 ^ i_op2;
            end
            `ALU_SUB, `ALU_RSB, `ALU_ADD, `ALU_ADC, `ALU_SBC, `ALU_RSC, `ALU_CMP, `ALU_CMN: begin
                o_result = adc_unit_result;
            end
            `ALU_ORR: begin
                o_result = i_op1 | i_op2;
            end
            `ALU_MOV: begin
                o_result = i_op2;
            end
            `ALU_BIC: begin
                o_result = i_op1 & (~i_op2);
            end
            `ALU_MVN: begin
                o_result = ~i_op2;
            end
        endcase
    end
    always @(*) begin
        case (i_opcode)
            `ALU_AND, `ALU_TST, `ALU_EOR, `ALU_TEQ, `ALU_ORR, `ALU_MOV, `ALU_BIC, `ALU_MVN: begin
                o_nzcv = {o_result[31], (o_result == 'd0), i_shift_carry, i_nzcv[0]};
            end
            `ALU_SUB, `ALU_RSB, `ALU_ADD, `ALU_ADC, `ALU_SBC, `ALU_RSC, `ALU_CMP, `ALU_CMN: begin
                o_nzcv = {o_result[31], (o_result == 'd0), adc_unit_carryout, adc_unit_overflowout};
            end
        endcase
    end
endmodule