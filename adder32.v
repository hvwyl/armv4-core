module adder32 (
    input [31:0]    i_op1,
    input [31:0]    i_op2,
    input           i_carry,
    output [31:0]   o_result,
    output          o_carry
);
    /*
        WARNING:
        For logic testing only.
    */
    assign {o_carry, o_result} = {1'b0, i_op1} + {1'b0, i_op2} + {32'b0, i_carry};
endmodule