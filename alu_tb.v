`timescale 1ns/1ps
`include "def.v"
module alu_tb ();
localparam NUM = 20;

// input data
reg [31:0] i_op1, i_op2;
reg [3:0] i_nzcv;
reg [3:0] i_opcode;
reg i_shift_carry;
// output data
wire [31:0] o_result;
wire [3:0] o_nzcv;
// reference data
wire [31:0] ref_o_result;
wire [3:0] ref_o_nzcv;
// pass?
wire pass;
assign pass = (o_result==ref_o_result)&&(o_nzcv==ref_o_nzcv);

function [33:0] AddWithCarry32;
    // Return type: {[31:0]result, carry, overflow}
    input [31:0] i_op1;
    input [31:0] i_op2;
    input i_carry;

    reg [32:0] unsigned_sum;

    reg [31:0] o_result;
    reg o_carry;
    reg o_overflow;

    begin
        unsigned_sum = {1'b0, i_op1} + {1'b0, i_op2} + {32'b0, i_carry};
        o_result = unsigned_sum[31:0];
        o_carry = unsigned_sum[32];
        o_overflow = (i_op1[31]==1 && i_op2[31]==1 && o_result[31]==0) || (i_op1[31]==0 && i_op2[31]==0 && o_result[31]==1);
        AddWithCarry32 = {o_result, o_carry, o_overflow};
    end
endfunction

function [35:0] ALU;
    // Return type: {[31:0]result, [3:0]nzcv}
    input [31:0] i_op1;
    input [31:0] i_op2;
    input [3:0] i_nzcv;
    input [3:0] i_opcode;
    input i_shift_carry;

    localparam N = 3;
    localparam Z = 2;
    localparam C = 1;
    localparam V = 0;
    reg [33:0] AddWithCarry32_result;
    localparam AddWithCarry32_R_MSB = 33;
    localparam AddWithCarry32_R_LSB = 2;
    localparam AddWithCarry32_C = 1;
    localparam AddWithCarry32_V = 0;

    reg [31:0] o_result;
    reg [3:0] o_nzcv;

    begin
        case (i_opcode)
            `ALU_AND: begin // Test AND
                o_result = i_op1 & i_op2;
                o_nzcv[N] = o_result[31];
                o_nzcv[Z] = (o_result==0)?1:0;
                o_nzcv[C] = i_shift_carry;
                o_nzcv[V] = i_nzcv[V];
            end
            `ALU_EOR: begin // Test EOR
                o_result = i_op1 ^ i_op2;
                o_nzcv[N] = o_result[31];
                o_nzcv[Z] = (o_result==0)?1:0;
                o_nzcv[C] = i_shift_carry;
                o_nzcv[V] = i_nzcv[V];
            end
            `ALU_SUB: begin // Test SUB
                // same datapath with ADR
                AddWithCarry32_result = AddWithCarry32(i_op1, ~i_op2, 1);
                o_result = AddWithCarry32_result[AddWithCarry32_R_MSB:AddWithCarry32_R_LSB];
                o_nzcv[N] = o_result[31];
                o_nzcv[Z] = (o_result==0)?1:0;
                o_nzcv[C] = AddWithCarry32_result[AddWithCarry32_C];
                o_nzcv[V] = AddWithCarry32_result[AddWithCarry32_V];
            end
            `ALU_RSB: begin // Test RSB
                AddWithCarry32_result = AddWithCarry32(~i_op1, i_op2, 1);
                o_result = AddWithCarry32_result[AddWithCarry32_R_MSB:AddWithCarry32_R_LSB];
                o_nzcv[N] = o_result[31];
                o_nzcv[Z] = (o_result==0)?1:0;
                o_nzcv[C] = AddWithCarry32_result[AddWithCarry32_C];
                o_nzcv[V] = AddWithCarry32_result[AddWithCarry32_V];
            end
            `ALU_ADD: begin // Test ADD
                // same datapath with ADR
                AddWithCarry32_result = AddWithCarry32(i_op1, i_op2, 0);
                o_result = AddWithCarry32_result[AddWithCarry32_R_MSB:AddWithCarry32_R_LSB];
                o_nzcv[N] = o_result[31];
                o_nzcv[Z] = (o_result==0)?1:0;
                o_nzcv[C] = AddWithCarry32_result[AddWithCarry32_C];
                o_nzcv[V] = AddWithCarry32_result[AddWithCarry32_V];
            end
            `ALU_ADC: begin // Test ADC
                AddWithCarry32_result = AddWithCarry32(i_op1, i_op2, i_nzcv[C]);
                o_result = AddWithCarry32_result[AddWithCarry32_R_MSB:AddWithCarry32_R_LSB];
                o_nzcv[N] = o_result[31];
                o_nzcv[Z] = (o_result==0)?1:0;
                o_nzcv[C] = AddWithCarry32_result[AddWithCarry32_C];
                o_nzcv[V] = AddWithCarry32_result[AddWithCarry32_V];
            end
            `ALU_SBC: begin // Test SBC
                AddWithCarry32_result = AddWithCarry32(i_op1, ~i_op2, i_nzcv[C]);
                o_result = AddWithCarry32_result[AddWithCarry32_R_MSB:AddWithCarry32_R_LSB];
                o_nzcv[N] = o_result[31];
                o_nzcv[Z] = (o_result==0)?1:0;
                o_nzcv[C] = AddWithCarry32_result[AddWithCarry32_C];
                o_nzcv[V] = AddWithCarry32_result[AddWithCarry32_V];
            end
            `ALU_RSC: begin // Test RSC
                AddWithCarry32_result = AddWithCarry32(~i_op1, i_op2, i_nzcv[C]);
                o_result = AddWithCarry32_result[AddWithCarry32_R_MSB:AddWithCarry32_R_LSB];
                o_nzcv[N] = o_result[31];
                o_nzcv[Z] = (o_result==0)?1:0;
                o_nzcv[C] = AddWithCarry32_result[AddWithCarry32_C];
                o_nzcv[V] = AddWithCarry32_result[AddWithCarry32_V];
            end
            `ALU_TST: begin // Test TST
                // same alu datapath with ALU_AND, wr_en implement in ctrl_unit
                o_result = i_op1 & i_op2;
                o_nzcv[N] = o_result[31];
                o_nzcv[Z] = (o_result==0)?1:0;
                o_nzcv[C] = i_shift_carry;
                o_nzcv[V] = i_nzcv[V];
            end
            `ALU_TEQ: begin // Test TEQ
                // same alu datapath with ALU_EOR, wr_en implement in ctrl_unit
                o_result = i_op1 ^ i_op2;
                o_nzcv[N] = o_result[31];
                o_nzcv[Z] = (o_result==0)?1:0;
                o_nzcv[C] = i_shift_carry;
                o_nzcv[V] = i_nzcv[V];
            end
            `ALU_CMP: begin // Test CMP
                // same alu datapath with ALU_SUB, wr_en implement in ctrl_unit
                AddWithCarry32_result = AddWithCarry32(i_op1, ~i_op2, 1);
                o_result = AddWithCarry32_result[AddWithCarry32_R_MSB:AddWithCarry32_R_LSB];
                o_nzcv[N] = o_result[31];
                o_nzcv[Z] = (o_result==0)?1:0;
                o_nzcv[C] = AddWithCarry32_result[AddWithCarry32_C];
                o_nzcv[V] = AddWithCarry32_result[AddWithCarry32_V];
            end
            `ALU_CMN: begin // Test CMN
                // same alu datapath with ALU_ADD, wr_en implement in ctrl_unit
                AddWithCarry32_result = AddWithCarry32(i_op1, i_op2, 0);
                o_result = AddWithCarry32_result[AddWithCarry32_R_MSB:AddWithCarry32_R_LSB];
                o_nzcv[N] = o_result[31];
                o_nzcv[Z] = (o_result==0)?1:0;
                o_nzcv[C] = AddWithCarry32_result[AddWithCarry32_C];
                o_nzcv[V] = AddWithCarry32_result[AddWithCarry32_V];
            end
            `ALU_ORR: begin // Test ORR
                o_result = i_op1 | i_op2;
                o_nzcv[N] = o_result[31];
                o_nzcv[Z] = (o_result==0)?1:0;
                o_nzcv[C] = i_shift_carry;
                o_nzcv[V] = i_nzcv[V];
            end
            `ALU_MOV: begin // Test MOV
                // logic operation (LSL, LSR, ASR, RRX, ROR) has the same alu datapath as move operation (MOV), it will be implemented in module shift_unit
                o_result = i_op2;
                o_nzcv[N] = o_result[31];
                o_nzcv[Z] = (o_result==0)?1:0;
                o_nzcv[C] = i_shift_carry;
                o_nzcv[V] = i_nzcv[V];
            end
            `ALU_BIC: begin // Test BIC
                o_result = i_op1 & (~i_op2);
                o_nzcv[N] = o_result[31];
                o_nzcv[Z] = (o_result==0)?1:0;
                o_nzcv[C] = i_shift_carry;
                o_nzcv[V] = i_nzcv[V];
            end
            `ALU_MVN: begin // Test MVN
                o_result = ~i_op2;
                o_nzcv[N] = o_result[31];
                o_nzcv[Z] = (o_result==0)?1:0;
                o_nzcv[C] = i_shift_carry;
                o_nzcv[V] = i_nzcv[V];
            end
        endcase
        ALU = {o_result, o_nzcv};
    end
endfunction

assign {ref_o_result, ref_o_nzcv} = ALU(i_op1, i_op2, i_nzcv, i_opcode, i_shift_carry);

initial begin
    i_opcode = 4'b1111;
    forever begin
        i_opcode = i_opcode + 1;
        repeat (NUM) begin
            #10
            i_op1 = $random;
            i_op2 = $random;
            i_nzcv = $random;
            i_shift_carry = $random;
        end
        if (i_opcode == 15) begin
            $finish;
        end
    end
end

alu alu_0(
    .i_op1          (i_op1),
    .i_op2          (i_op2),
    .i_nzcv         (i_nzcv),
    .i_opcode       (i_opcode),
    .i_shift_carry  (i_shift_carry),

    .o_result       (o_result),
    .o_nzcv         (o_nzcv)
);
endmodule