`define SHIFT_LSL   3'b000
`define SHIFT_LSR   3'b001
`define SHIFT_ASR   3'b010
`define SHIFT_ROR   3'b011
`define SHIFT_RRX   3'b100
// `define SHIFT_NONE  3'b1xx // xx!=00
`define SHIFT_NONE  3'b111

`define ALU_AND     4'b0000
`define ALU_EOR     4'b0001
`define ALU_SUB     4'b0010
`define ALU_RSB     4'b0011
`define ALU_ADD     4'b0100
`define ALU_ADC     4'b0101
`define ALU_SBC     4'b0110
`define ALU_RSC     4'b0111
`define ALU_TST     4'b1000
`define ALU_TEQ     4'b1001
`define ALU_CMP     4'b1010
`define ALU_CMN     4'b1011
`define ALU_ORR     4'b1100
`define ALU_MOV     4'b1101
`define ALU_BIC     4'b1110
`define ALU_MVN     4'b1111

`define MEM_B       2'b00   // byte
`define MEM_H       2'b01   // half word
`define MEM_W       2'b10   // word
// `define MEM_D       2'b11   // double