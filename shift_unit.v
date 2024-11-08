`include "def.v"
module shift_unit (
    input [31:0]        i_op,
    input [2:0]         i_type,     // 0: LSL, 1: LSR, 2: ASR, 3: ROR, 4: RRX, other: bypass
    input [7:0]         i_amount,   // range 0 to 255
    input               i_carry,
    output reg [31:0]   o_result,
    output reg          o_carry
);

    // LSL module
    wire [31:0] lsl_result;
    wire lsl_carry;
    shift #(
        .DATA_WIDTH (32),
        .SHIFT_TYPE ("LSL")
    ) shift_lsl_0 (
        .i_op       (i_op),
        .i_amount   (i_amount[4:0]),
        .i_carry    (i_carry),
        .o_result   (lsl_result),
        .o_carry    (lsl_carry)
    );

    // LSR module
    wire [31:0] lsr_result;
    wire lsr_carry;
    shift #(
        .DATA_WIDTH (32),
        .SHIFT_TYPE ("LSR")
    ) shift_lsr_0 (
        .i_op       (i_op),
        .i_amount   (i_amount[4:0]),
        .i_carry    (i_carry),
        .o_result   (lsr_result),
        .o_carry    (lsr_carry)
    );

    // ASR module
    wire [31:0] asr_result;
    wire asr_carry;
    shift #(
        .DATA_WIDTH (32),
        .SHIFT_TYPE ("ASR")
    ) shift_asr_0 (
        .i_op       (i_op),
        .i_amount   (i_amount[4:0]),
        .i_carry    (i_carry),
        .o_result   (asr_result),
        .o_carry    (asr_carry)
    );

    // ROR module
    wire [31:0] ror_result;
    wire ror_carry;
    shift #(
        .DATA_WIDTH (32),
        .SHIFT_TYPE ("ROR")
    ) shift_ror_0 (
        .i_op       (i_op),
        .i_amount   (i_amount[4:0]),
        .i_carry    (i_carry),
        .o_result   (ror_result),
        .o_carry    (ror_carry)
    );
    
    // ctrl
    always @(*) begin
        case (i_type)
            `SHIFT_LSL: begin
                // LSL
                if (i_amount == 8'd32) begin
                    o_result = 'b0;
                    o_carry = i_op[0];
                end
                else if ((|i_amount[7:5]) != 'b1) begin
                    o_result = lsl_result;
                    o_carry = lsl_carry;
                end
                else begin
                    o_result = 'b0;
                    o_carry = 'b0;
                end
            end
            `SHIFT_LSR: begin
                // LSR
                if (i_amount == 8'd32) begin
                    o_result = 'b0;
                    o_carry = i_op[31];
                end
                else if ((|i_amount[7:5]) != 'b1) begin
                    o_result = lsr_result;
                    o_carry = lsr_carry;
                end
                else begin
                    o_result = 'b0;
                    o_carry = 'b0;
                end
            end
            `SHIFT_ASR: begin
                // ASR
                if ((|i_amount[7:5]) != 'b1) begin
                    o_result = asr_result;
                    o_carry = asr_carry;
                end
                else begin
                    o_result = {32{i_op[31]}};
                    o_carry = i_op[31];
                end
            end
            `SHIFT_ROR: begin
                // ROR
                o_result = ror_result;
                o_carry = ror_carry;
            end
            `SHIFT_RRX: begin
                // RRX
                o_result = {i_carry, i_op[31:1]};
                o_carry = i_op[0];
            end
            default: begin
                // no shift
                o_result = i_op;
                o_carry = i_carry;
            end
        endcase
    end
endmodule