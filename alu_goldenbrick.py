import random

ALU_OP_AND = 0b0000
ALU_OP_EOR = 0b0001
ALU_OP_SUB = 0b0010 # same datapath with ADR
ALU_OP_RSB = 0b0011
ALU_OP_ADD = 0b0100 # same datapath with ADR
ALU_OP_ADC = 0b0101
ALU_OP_SBC = 0b0110
ALU_OP_RSC = 0b0111
ALU_OP_TST = 0b1000 # same alu datapath with ALU_OP_AND, wr_en implement in ctrl_unit
ALU_OP_TEQ = 0b1001 # same alu datapath with ALU_OP_EOR, wr_en implement in ctrl_unit
ALU_OP_CMP = 0b1010 # same alu datapath with ALU_OP_SUB, wr_en implement in ctrl_unit
ALU_OP_CMN = 0b1011 # same alu datapath with ALU_OP_ADD, wr_en implement in ctrl_unit
ALU_OP_ORR = 0b1100
ALU_OP_MOV = 0b1101 # logic operation (LSL, LSR, ASR, RRX, ROR) has the same alu datapath as move operation (MOV), it will implement in shift_unit
ALU_OP_BIC = 0b1110
ALU_OP_MVN = 0b1111 # opertaion to shifted(i_op2), i_op1 will be discarded

def AddWithCarry(op1, op2, c):
    unsigned_sum = op1 + op2 + c
    result = unsigned_sum & 0xFFFFFFFF
    carry_out = (unsigned_sum>>32)&0x01
    op1_sign = (op1>>31)&0x01
    op2_sign = (op2>>31)&0x01
    result_sign = (result>>31)&0x01
    overflow = (op1_sign==1 and op2_sign==1 and result_sign==0) or (op1_sign==0 and op2_sign==0 and result_sign==1)
    return result, carry_out, overflow

with open("alu_goldenbrick.txt", "w") as f:
    for opcode in range(16):
        for i in range(20):
            i_op1 = random.randint(0, 0xFFFFFFFF)
            i_op2 = random.randint(0, 0xFFFFFFFF)
            i_n = random.randint(0, 1)
            i_z = random.randint(0, 1)
            i_c = random.randint(0, 1)
            i_v = random.randint(0, 1)
            i_opcode = opcode
            i_shift_carry = random.randint(0, 1)
            if opcode == ALU_OP_AND:    # Test AND
                o_result = i_op1 & i_op2
                o_n, o_z = (o_result>>31)&0x01, 1 if o_result==0 else 0
                o_c = i_shift_carry
                o_v = i_v
            elif opcode == ALU_OP_EOR:  # Test EOR
                o_result = i_op1 ^ i_op2
                o_n, o_z = (o_result>>31)&0x01, 1 if o_result==0 else 0
                o_c = i_shift_carry
                o_v = i_v
            elif opcode == ALU_OP_SUB:  # Test SUB
                o_result, tmp_carry, tmp_overflow = AddWithCarry(i_op1, (~i_op2)&0xFFFFFFFF, 1)
                o_n, o_z = (o_result>>31)&0x01, 1 if o_result==0 else 0
                o_c = tmp_carry
                o_v = tmp_overflow
            elif opcode == ALU_OP_RSB:  # Test RSB
                o_result, tmp_carry, tmp_overflow = AddWithCarry((~i_op1)&0xFFFFFFFF, i_op2, 1)
                o_n, o_z = (o_result>>31)&0x01, 1 if o_result==0 else 0
                o_c = tmp_carry
                o_v = tmp_overflow
            elif opcode == ALU_OP_ADD:  # Test ADD
                o_result, tmp_carry, tmp_overflow = AddWithCarry(i_op1, i_op2, 0)
                o_n, o_z = (o_result>>31)&0x01, 1 if o_result==0 else 0
                o_c = tmp_carry
                o_v = tmp_overflow
            elif opcode == ALU_OP_ADC:  # Test ADC
                o_result, tmp_carry, tmp_overflow = AddWithCarry(i_op1, i_op2, i_c)
                o_n, o_z = (o_result>>31)&0x01, 1 if o_result==0 else 0
                o_c = tmp_carry
                o_v = tmp_overflow
            elif opcode == ALU_OP_SBC:  # Test SBC
                o_result, tmp_carry, tmp_overflow = AddWithCarry(i_op1, (~i_op2)&0xFFFFFFFF, i_c)
                o_n, o_z = (o_result>>31)&0x01, 1 if o_result==0 else 0
                o_c = tmp_carry
                o_v = tmp_overflow
            elif opcode == ALU_OP_RSC:  # Test RSC
                o_result, tmp_carry, tmp_overflow = AddWithCarry((~i_op1)&0xFFFFFFFF, i_op2, i_c)
                o_n, o_z = (o_result>>31)&0x01, 1 if o_result==0 else 0
                o_c = tmp_carry
                o_v = tmp_overflow
            elif opcode == ALU_OP_TST:  # Test TST
                o_result = i_op1 & i_op2
                o_n, o_z = (o_result>>31)&0x01, 1 if o_result==0 else 0
                o_c = i_shift_carry
                o_v = i_v
            elif opcode == ALU_OP_TEQ:  # Test TEQ
                o_result = i_op1 ^ i_op2
                o_n, o_z = (o_result>>31)&0x01, 1 if o_result==0 else 0
                o_c = i_shift_carry
                o_v = i_v
            elif opcode == ALU_OP_CMP:  # Test CMP
                o_result, tmp_carry, tmp_overflow = AddWithCarry(i_op1, (~i_op2)&0xFFFFFFFF, 1)
                o_n, o_z = (o_result>>31)&0x01, 1 if o_result==0 else 0
                o_c = tmp_carry
                o_v = tmp_overflow
            elif opcode == ALU_OP_CMN:  # Test CMN
                o_result, tmp_carry, tmp_overflow = AddWithCarry(i_op1, i_op2, 0)
                o_n, o_z = (o_result>>31)&0x01, 1 if o_result==0 else 0
                o_c = tmp_carry
                o_v = tmp_overflow
            elif opcode == ALU_OP_ORR:  # Test ORR
                o_result = i_op1 | i_op2
                o_n, o_z = (o_result>>31)&0x01, 1 if o_result==0 else 0
                o_c = i_shift_carry
                o_v = i_v
            elif opcode == ALU_OP_MOV:  # Test MOV
                o_result = i_op2
                o_n, o_z = (o_result>>31)&0x01, 1 if o_result==0 else 0
                o_c = i_shift_carry
                o_v = i_v
            elif opcode == ALU_OP_BIC:  # Test BIC
                o_result = i_op1 & ((~i_op2)&0xFFFFFFFF)
                o_n, o_z = (o_result>>31)&0x01, 1 if o_result==0 else 0
                o_c = i_shift_carry
                o_v = i_v
            elif opcode == ALU_OP_MVN:  # Test MVN
                o_result = (~i_op2)&0xFFFFFFFF
                o_n, o_z = (o_result>>31)&0x01, 1 if o_result==0 else 0
                o_c = i_shift_carry
                o_v = i_v
            f.write("i_op1={:0>8X} i_op2={:0>8X} i_nzcv={:b}{:b}{:b}{:b} i_opcode={:0>4b} i_shift_carry={:b} o_result={:0>8X} o_nzcv={:b}{:b}{:b}{:b}\n".format(i_op1, i_op2, i_n, i_z, i_c, i_v, i_opcode, i_shift_carry, o_result, o_n, o_z, o_c, o_v))
    f.close()