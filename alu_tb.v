`timescale 1ns/1ps
module alu_tb ();
// input data
reg [31:0] i_op1, i_op2;
reg [3:0] i_nzcv;
reg [3:0] i_opcode;
reg i_shift_carry;
// output data
wire [31:0] o_result;
wire [3:0] o_nzcv;
// reference data
reg [31:0] ref_o_result;
reg [3:0] ref_o_nzcv;
// pass?
wire pass;
assign pass = (o_result==ref_o_result)&&(o_nzcv==ref_o_nzcv);

integer read_file;
initial begin
    read_file = $fopen("alu_goldenbrick.txt", "r");
    while (!$feof(read_file)) begin
        #10
        $fscanf(read_file, "i_op1=%X i_op2=%X i_nzcv=%b i_opcode=%b i_shift_carry=%b o_result=%X o_nzcv=%b", i_op1, i_op2, i_nzcv, i_opcode, i_shift_carry, ref_o_result, ref_o_nzcv); 
    end
    $stop;
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