`include "def.v"
module id_stage (
    /* instruction code input */
    input               i_inst_vld,
    input [31:0]        i_inst,

    /* nzcv passby */
    input [3:0]         i_nzcv_next,

    /* PC input */
    input [31:0]        i_pc,

    /* rm, rn, rs register code output */
    output reg [3:0]    o_rm_code,
    output reg [3:0]    o_rn_code,
    output reg [3:0]    o_rs_code,
    output reg          o_rm_code_vld,
    output reg          o_rn_code_vld,
    output reg          o_rs_code_vld,

    /* rm, rn, rs register value input */
    input [31:0]        i_rm_reg,
    input [31:0]        i_rn_reg,
    input [31:0]        i_rs_reg,

    /* operand output */
    output reg [31:0]   o_op1,
    output reg [31:0]   o_op2,
    output reg [7:0]    o_shift,
    output reg [2:0]    o_shift_type,
    output reg [31:0]   o_op3,
    output reg [3:0]    o_opcode,

    /* standard data path control signals output */
    output reg          o_mem_vld,
    output reg [1:0]    o_mem_size,
    output reg          o_mem_sign,
    output reg          o_mem_addr_src,
    output reg          o_rd_vld,
    output reg [3:0]    o_rd_code,
    output reg          o_wb_rd_vld,
    output reg [3:0]    o_wb_rd_code,
    output reg          o_nzcv_flag,
    
    /* multiplier control signals */
    output              o_mul_vld,

    /* high-priority function control signals */
    output reg          o_swp_vld,      // SWP instruction
    output reg          o_ldm_vld,      // LDM instruction
    output reg          o_mrs_vld,      // MRS instruction
    output reg          o_msr_vld,      // MSR instruction

    /* to ldm_ctrl */
    output              o_ldm_p,
    output              o_ldm_u,
    output              o_ldm_s,
    output              o_ldm_l,
    output [15:0]       o_ldm_reglist
);
    /* cond check */
    wire cpsr_n, cpsr_z, cpsr_c, cpsr_v;
    assign {cpsr_n, cpsr_z, cpsr_c, cpsr_v} = i_nzcv_next;
    reg cond_vld;
    always @(*) begin
        case (i_inst[31:28])
            4'h0: cond_vld = i_inst_vld & (cpsr_z==1'b1);
            4'h1: cond_vld = i_inst_vld & (cpsr_z==1'b0);
            4'h2: cond_vld = i_inst_vld & (cpsr_c==1'b1);
            4'h3: cond_vld = i_inst_vld & (cpsr_c==1'b0);
            4'h4: cond_vld = i_inst_vld & (cpsr_n==1'b1);
            4'h5: cond_vld = i_inst_vld & (cpsr_n==1'b0);
            4'h6: cond_vld = i_inst_vld & (cpsr_v==1'b1);
            4'h7: cond_vld = i_inst_vld & (cpsr_v==1'b0);
            4'h8: cond_vld = i_inst_vld & ((cpsr_c==1'b1)&(cpsr_z==1'b0));
            4'h9: cond_vld = i_inst_vld & ((cpsr_c==1'b0)|(cpsr_z==1'b1));
            4'ha: cond_vld = i_inst_vld & (cpsr_n==cpsr_v);
            4'hb: cond_vld = i_inst_vld & (cpsr_n!=cpsr_v);
            4'hc: cond_vld = i_inst_vld & ((cpsr_z==1'b0)&(cpsr_n==cpsr_v));
            4'hd: cond_vld = i_inst_vld & ((cpsr_z==1'b1)|(cpsr_n!=cpsr_v));
            4'he: cond_vld = i_inst_vld & 1'b1;
            4'hf: cond_vld = i_inst_vld & 1'b0;
        endcase
    end

    /* instruction decode */
    wire is_dp0,
        is_dp1,
        is_dp2,
        is_b,
        is_ldr0,
        is_ldr1,
        is_ldrh0,
        is_ldrh1,
        is_ldrsb0,
        is_ldrsb1,
        is_ldrsh0,
        is_ldrsh1,
        is_swp,
        is_ldm,
        is_mrs,
        is_msr,
        is_mul,
        is_mull;
    assign is_dp0 = ({i_inst[27:25],i_inst[4]}==4'b0000)&((i_inst[24:23]!=2'b10)|i_inst[20]);
    assign is_dp1 = ({i_inst[27:25],i_inst[7],i_inst[4]}==5'b00001) & ((i_inst[24:23]!=2'b10)|i_inst[20]);
    assign is_dp2 = (i_inst[27:25]==3'b001)&((i_inst[24:23]!=2'b10)|i_inst[20]);
    assign is_b = (i_inst[27:25]==4'b101);
    assign is_ldr0 = (i_inst[27:25]==3'b010);
    assign is_ldr1 = ({i_inst[27:25],i_inst[4]}==4'b0110);
    assign is_ldrh0 = ({i_inst[27:25],i_inst[22],i_inst[11:4]}==12'b000_0_00001011);
    assign is_ldrh1 = ({i_inst[27:25],i_inst[22],i_inst[7:4]}==8'b000_1_1011);
    assign is_ldrsb0 = ({i_inst[27:25],i_inst[22],i_inst[20],i_inst[11:4]}==13'b000_0_1_00001101);
    assign is_ldrsb1 = ({i_inst[27:25],i_inst[22],i_inst[20],i_inst[7:4]}==9'b000_1_1_1101);
    assign is_ldrsh0 = ({i_inst[27:25],i_inst[22],i_inst[20],i_inst[11:4]}==13'b000_0_1_00001111);
    assign is_ldrsh1 = ({i_inst[27:25],i_inst[22],i_inst[20],i_inst[7:4]}==9'b000_1_1_1111);
    assign is_swp = ({i_inst[27:23],i_inst[21:20],i_inst[11:4]}==15'b00010_00_00001001);
    assign is_ldm = (i_inst[27:25]==3'b100);
    assign is_mrs = ({i_inst[27:23],i_inst[21:20],i_inst[7],i_inst[4]}==9'b000100000);
    assign is_msr = ({i_inst[27:23],i_inst[21:20],i_inst[7],i_inst[4]}==9'b000101000);
    assign is_mul = ({i_inst[27:22],i_inst[7:4]}==10'b0000_00_1001);
    assign is_mull = ({i_inst[27:23],i_inst[7:4]}==9'b0000_1_1001);

    /* regcode decode */
    // Rm is always i_inst[3:0]
    // Rn is always i_inst[19:16] or 4'b1111
    // Rs is always i_inst[11:8]
    // Rd is always i_inst[15:12]
    wire [3:0] rm_code, rn_code, rs_code, rd_code;
    assign rm_code = i_inst[3:0];
    assign rn_code = (is_b)?4'b1111:i_inst[19:16];
    assign rs_code = i_inst[11:8];
    assign rd_code = i_inst[15:12];

    /* imm5shift decode */
    reg [7:0] imm5_shift;
    reg [2:0] imm5_shift_type;
    always @(*) begin
        case (i_inst[6:5])
            2'b00: begin
                imm5_shift = {3'b000, i_inst[11:7]};
                imm5_shift_type = `SHIFT_LSL; // LSL
            end
            2'b01: begin
                if (i_inst[11:7] == 5'b00000) imm5_shift = 8'd32;
                else imm5_shift = {3'b000, i_inst[11:7]};
                imm5_shift_type = `SHIFT_LSR; // LSR
            end
            2'b10: begin
                if (i_inst[11:7] == 5'b00000) imm5_shift = 8'd32;
                else imm5_shift = {3'b000, i_inst[11:7]};
                imm5_shift_type = `SHIFT_ASR; // ASR
            end
            2'b11: begin
                imm5_shift = {3'b000, i_inst[11:7]};
                if (i_inst[11:7] == 5'b00000) imm5_shift_type = `SHIFT_RRX; // RRX
                else imm5_shift_type = `SHIFT_ROR; // ROR
            end
        endcase
    end

    /* mem instruction decode */
    // P is always i_inst[24]
    // U is always i_inst[23]
    // B is always i_inst[22]
    // W is always i_inst[21]
    // L is always i_inst[20]
    wire mem_p, mem_u, mem_b, mem_w, mem_l;
    assign {mem_p, mem_u, mem_b, mem_w, mem_l} = i_inst[24:20];

    /* ldm instruction decode */
    wire ldm_p, ldm_u, ldm_s, ldm_w, ldm_l;
    wire [15:0] ldm_reglist;
    assign {ldm_p, ldm_u, ldm_s, ldm_w, ldm_l} = i_inst[24:20];
    assign ldm_reglist = i_inst[15:0];

    assign {o_ldm_p, o_ldm_u, o_ldm_s, o_ldm_l, o_ldm_reglist} = {ldm_p, ldm_u, ldm_s, ldm_l, ldm_reglist};

    /* regcode router */
    always @(*) begin
        // Rm, Rn, Rs code
        if (is_ldr0||is_ldr1||is_ldrh0||is_ldrh1) begin
            // Multiplex Rs datapath and Rd datapath, in order to write mem from Rd
            // Rm and Rn will be used for generate address, and the generation of the mem_strb signal will be completed in EX stage
            o_rm_code = rm_code;
            o_rn_code = rn_code;
            o_rs_code = rd_code;
        end
        else if (is_mul||is_mull) begin
            // Multiplex Rm datapath and Rn datapath
            // Multiplex Rs datapath and Rm datapath
            o_rm_code = rm_code;
            o_rn_code = rd_code; // Ra is always i_inst[15:12], the same datapath as Rd
            o_rs_code = rs_code;
            // for mul operations of long types:
            // RdLo has the same datapath as Rd, and it will be acc_lo operand by multiplexing op1 datapath
            // RdHi code will be deferred to the next stage of the pipeline, and the acc_hi operand will be obtained through Re
        end
        else begin
            o_rm_code = rm_code;
            o_rn_code = rn_code;
            o_rs_code = rs_code;
        end
        // Rd code
        if (is_b) begin
            o_rd_code = 4'd15;
            o_wb_rd_code = 4'd14; // BL instruction will write op3 into R14
        end
        else if (is_ldr0||is_ldr1||is_ldm||is_mul) begin
            o_rd_code = rn_code; // Rn Write Back
            o_wb_rd_code = rd_code;
        end
        else if (is_mull) begin
            // RdLo is always i_inst[15:12], same as Rd
            // RdHi is always i_inst[19:16], same as Rn
            o_rd_code = rd_code;
            o_wb_rd_code = rn_code; // RdHi Write Back
        end
        else begin
            o_rd_code = rd_code;
            o_wb_rd_code = rd_code;
        end
    end

    /* operand output */
    always @(*) begin
        if (is_dp0) begin
            o_op1 = i_rn_reg;
            o_op2 = i_rm_reg;
            o_shift = imm5_shift;
            o_shift_type = imm5_shift_type;
            o_op3 = 'b0;
            o_opcode = i_inst[24:21];
            o_rm_code_vld = 'b1;
            o_rn_code_vld = ({i_inst[24:23], i_inst[21]}!=3'b111); // MOV, MVN instruction do not use Rn register
            o_rs_code_vld = 'b0;
        end
        else if (is_dp1) begin
            o_op1 = i_rn_reg;
            o_op2 = i_rm_reg;
            o_shift = i_rs_reg[7:0];
            o_shift_type = {1'b0, i_inst[6:5]};
            o_op3 = 'b0;
            o_opcode = i_inst[24:21];
            o_rm_code_vld = 'b1;
            o_rn_code_vld = ({i_inst[24:23], i_inst[21]}!=3'b111); // MOV, MVN instruction do not use Rn register
            o_rs_code_vld = 'b1;
        end
        else if (is_dp2) begin
            o_op1 = i_rn_reg;
            o_op2 = {24'b0, i_inst[7:0]};
            o_shift = {3'b0, i_inst[11:8], 1'b0};
            o_shift_type = `SHIFT_ROR; // ROR
            o_op3 = 'b0;
            o_opcode = i_inst[24:21];
            o_rm_code_vld = 'b0;
            o_rn_code_vld = ({i_inst[24:23], i_inst[21]}!=3'b111); // MOV, MVN instruction do not use Rn register
            o_rs_code_vld = 'b0;
        end
        else if (is_b) begin
            o_op1 = i_rn_reg;
            o_op2 = {{6{i_inst[23]}}, i_inst[23:0], 2'b0};
            o_shift = 8'd0;
            o_shift_type = `SHIFT_NONE; // noshift
            o_op3 = i_pc;               // BL instruction will write op3 into R14
            o_opcode = `ALU_ADD;
            o_rm_code_vld = 'b0;
            o_rn_code_vld = 'b1;
            o_rs_code_vld = 'b0;
        end
        else if (is_ldr0) begin
            o_op1 = i_rn_reg;
            o_op2 = {20'b0, i_inst[11:0]};
            o_shift = 8'd0;
            o_shift_type = `SHIFT_NONE; // noshift
            o_op3 = i_rs_reg; // Multiplexed Rd datapath in Rs
            if (mem_u) o_opcode = `ALU_ADD;
            else o_opcode = `ALU_SUB;
            o_rm_code_vld = 'b0;
            o_rn_code_vld = 'b1;
            o_rs_code_vld = ~mem_l; // read operation, do not use Rd register
        end
        else if (is_ldr1) begin
            o_op1 = i_rn_reg;
            o_op2 = i_rm_reg;
            o_shift = imm5_shift;
            o_shift_type = imm5_shift_type;
            o_op3 = i_rs_reg; // Multiplexed Rd datapath in Rs
            if (mem_u) o_opcode = `ALU_ADD;
            else o_opcode = `ALU_SUB;
            o_rm_code_vld = 'b1;
            o_rn_code_vld = 'b1;
            o_rs_code_vld = ~mem_l; // read operation, do not use Rd register
        end
        else if (is_ldrh0||is_ldrsb0||is_ldrsh0) begin
            o_op1 = i_rn_reg;
            o_op2 = i_rm_reg;
            o_shift = 8'd0;
            o_shift_type = `SHIFT_NONE; // noshift
            o_op3 = i_rs_reg; // Multiplexed Rd datapath in Rs
            if (mem_u) o_opcode = `ALU_ADD;
            else o_opcode = `ALU_SUB;
            o_rm_code_vld = 'b1;
            o_rn_code_vld = 'b1;
            o_rs_code_vld = ~mem_l; // read operation, do not use Rd register
        end
        else if (is_ldrh1||is_ldrsb1||is_ldrsh1) begin
            o_op1 = i_rn_reg;
            o_op2 = {24'b0, i_inst[11:8], i_inst[3:0]};
            o_shift = 8'd0;
            o_shift_type = `SHIFT_NONE; // noshift
            o_op3 = i_rs_reg; // Multiplexed Rd datapath in Rs
            if (mem_u) o_opcode = `ALU_ADD;
            else o_opcode = `ALU_SUB;
            o_rm_code_vld = 'b0;
            o_rn_code_vld = 'b1;
            o_rs_code_vld = ~mem_l; // read operation, do not use Rd register
        end
        else if (is_swp) begin
            o_op1 = i_rn_reg;
            o_op2 = 32'b0;
            o_shift = 8'd0;
            o_shift_type = `SHIFT_NONE; // noshift
            o_op3 = i_rm_reg;
            o_opcode = `ALU_AND;
            o_rm_code_vld = 'b1;
            o_rn_code_vld = 'b1;
            o_rs_code_vld = 'b0;
        end
        else if(is_ldm) begin
            o_op1 = i_rn_reg;
            o_op2 = 32'b0;
            o_shift = 8'd0;
            o_shift_type = `SHIFT_NONE; // noshift
            o_op3 = 'b0;
            if (ldm_u) o_opcode = `ALU_ADD;
            else o_opcode = `ALU_SUB;
            o_rm_code_vld = 'b0;
            o_rn_code_vld = 'b1;
            o_rs_code_vld = 'b0;
        end
        else if (is_msr) begin
            o_op1 = 32'b0;
            o_op2 = i_rm_reg;
            o_shift = 'b0;
            o_shift_type = `SHIFT_NONE; // noshift
            o_op3 = 'b0;
            o_opcode = `ALU_ORR;
            o_rm_code_vld = 'b1;
            o_rn_code_vld = 'b0;
            o_rs_code_vld = 'b0;
        end
        else if (is_mul||is_mull) begin
            o_op1 = i_rn_reg; // Multiplexed Ra datapath in Rn
            o_op2 = i_rm_reg; // Multiplexed Rn datapath in Rm
            o_shift = 'b0;
            o_shift_type = `SHIFT_NONE; // noshift
            o_op3 = i_rs_reg; // Multiplexed Rm datapath in Rs
            o_opcode = `ALU_ORR;
            o_rm_code_vld = 'b1;
            o_rn_code_vld = 'b1;
            o_rs_code_vld = 'b1;
        end
        else begin
            o_op1 = i_rn_reg;
            o_op2 = i_rm_reg;
            o_shift = 'b0;
            o_shift_type = `SHIFT_NONE; // noshift
            o_op3 = 'b0;
            o_opcode = `ALU_AND;
            o_rm_code_vld = 'b0;
            o_rn_code_vld = 'b0;
            o_rs_code_vld = 'b0;
        end
    end

    /* standard data path control signals output */
    always @(*) begin
        if (cond_vld && (is_dp0||is_dp1||is_dp2)) begin
            o_mem_vld = 'b0;
            o_mem_size = `MEM_W;
            o_mem_sign = 'b0;
            o_mem_addr_src = 'b1;
            o_rd_vld = (i_inst[24:23]!=2'b10);  // TST, TEQ, CMP, CMN do not write register
            o_wb_rd_vld = 'b0;
            o_nzcv_flag = i_inst[20];
        end
        else if (cond_vld && is_b) begin
            o_mem_vld = 'b0;
            o_mem_size = `MEM_W;
            o_mem_sign = 'b0;
            o_mem_addr_src = 'b1;
            o_rd_vld = 'b1;
            o_wb_rd_vld = i_inst[24]; // BL instruction will write op3 into R14
            o_nzcv_flag = 'b0;
        end
        else if (cond_vld && (is_ldr0||is_ldr1)) begin
            o_mem_vld = 'b1;
            case (mem_b)
                1'b0: o_mem_size = `MEM_W;
                1'b1: o_mem_size = `MEM_B;
            endcase
            o_mem_sign = 'b0;
            o_mem_addr_src = (mem_p==1'b1); // P=1, use ALU result, or use op1
            o_rd_vld = ((mem_w==1'b1)||(mem_p==1'b0)); // W=1 or P=0, writeback rn
            o_wb_rd_vld = mem_l; // L=1, load data from mem
            o_nzcv_flag = 'b0;
        end
        else if (cond_vld && (is_ldrh0||is_ldrh1)) begin
            o_mem_vld = 'b1;
            o_mem_size = `MEM_H;
            o_mem_sign = 'b0;
            o_mem_addr_src = (mem_p==1'b1);
            o_rd_vld = ((mem_w==1'b1)||(mem_p==1'b0)); // W=1 or P=0, writeback rn
            o_wb_rd_vld = mem_l; // L=1, load data from mem
            o_nzcv_flag = 'b0;
        end
        else if (cond_vld && (is_ldrsb0||is_ldrsb1)) begin
            o_mem_vld = 'b1;
            o_mem_size = `MEM_B;
            o_mem_sign = 'b1;
            o_mem_addr_src = (mem_p==1'b1);
            o_rd_vld = ((mem_w==1'b1)||(mem_p==1'b0)); // W=1 or P=0, writeback rn
            o_wb_rd_vld = 'b1; // load data from mem
            o_nzcv_flag = 'b0;
        end
        else if (cond_vld && (is_ldrsh0||is_ldrsh1)) begin
            o_mem_vld = 'b1;
            o_mem_size = `MEM_H;
            o_mem_sign = 'b1;
            o_mem_addr_src = (mem_p==1'b1);
            o_rd_vld = ((mem_w==1'b1)||(mem_p==1'b0)); // W=1 or P=0, writeback rn
            o_wb_rd_vld = 'b1; // load data from mem
            o_nzcv_flag = 'b0;
        end
        else if (cond_vld && is_swp) begin
            o_mem_vld = 'b1;
            case (mem_b)
                1'b0: o_mem_size = `MEM_W;
                1'b1: o_mem_size = `MEM_B;
            endcase
            o_mem_sign = 'b0;
            o_mem_addr_src = 'b1;
            o_rd_vld = 'b0;
            o_wb_rd_vld = 'b1;
            o_nzcv_flag = 'b0;
        end
        else if (cond_vld && is_ldm) begin
            o_mem_vld = 'b1;
            o_mem_size = `MEM_W;
            o_mem_sign = 'b0;
            o_mem_addr_src = 'b1;
            o_rd_vld = ldm_w;
            o_wb_rd_vld = ldm_l;
            o_nzcv_flag = 'b0;
        end
        else if (cond_vld && is_mrs) begin
            o_mem_vld = 'b0;
            o_mem_size = `MEM_W;
            o_mem_sign = 'b0;
            o_mem_addr_src = i_inst[22]; // Multiplexed mem_addr_src datapath in xpsr_sel
            o_rd_vld = 'b1;
            o_wb_rd_vld = 'b0;
            o_nzcv_flag = 'b0;
        end
        else if (cond_vld && is_msr) begin
            o_mem_vld = 'b0;
            o_mem_size = `MEM_W;
            o_mem_sign = 'b0;
            o_mem_addr_src = i_inst[22]; // Multiplexed mem_addr_src datapath in xpsr_sel
            o_rd_vld = 'b0;
            o_wb_rd_vld = 'b0;
            o_nzcv_flag = 'b0;
        end
        else if (cond_vld && (is_mul)) begin
            o_mem_vld = 'b0;
            o_mem_size = `MEM_W;
            o_mem_sign = 'b0;
            o_mem_addr_src = 'b1;
            o_rd_vld = 'b1;
            o_wb_rd_vld = 'b0;
            o_nzcv_flag = i_inst[20];
        end
        else if (cond_vld && (is_mull)) begin
            o_mem_vld = 'b0;
            o_mem_size = `MEM_W;
            o_mem_sign = 'b0;
            o_mem_addr_src = 'b1;
            o_rd_vld = 'b1;
            o_wb_rd_vld = 'b1; // Write RdHi register in WB phase
            o_nzcv_flag = i_inst[20];
        end
        else begin
            o_mem_vld = 'b0;
            o_mem_size = `MEM_W;
            o_mem_sign = 'b0;
            o_mem_addr_src = 'b1;
            o_rd_vld = 'b0;
            o_wb_rd_vld = 'b0;
            o_nzcv_flag = 'b0;
        end
    end

    /* multiplier control signals */
    assign o_mul_vld = cond_vld && (is_mul||is_mull);
    
    /* high-priority function control signals */
    always @(*) begin
        if (cond_vld && is_swp) begin
            o_swp_vld = 'b1;
            o_ldm_vld = 'b0;
            o_mrs_vld = 'b0;
            o_msr_vld = 'b0;
        end
        else if (cond_vld && is_ldm) begin
            o_swp_vld = 'b0;
            o_ldm_vld = 'b1;
            o_mrs_vld = 'b0;
            o_msr_vld = 'b0;
        end
        else if (cond_vld && is_mrs) begin
            o_swp_vld = 'b0;
            o_ldm_vld = 'b0;
            o_mrs_vld = 'b1;
            o_msr_vld = 'b0;
        end
        else if (cond_vld && is_msr) begin
            o_swp_vld = 'b0;
            o_ldm_vld = 'b0;
            o_mrs_vld = 'b0;
            o_msr_vld = 'b1;
        end
        else begin
            o_swp_vld = 'b0;
            o_ldm_vld = 'b0;
            o_mrs_vld = 'b0;
            o_msr_vld = 'b0;
        end
    end

endmodule