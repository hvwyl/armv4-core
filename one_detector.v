module one_detector (
    input [15:0]    i_code,
    input           i_order,    // order=1: from LSB to MSB, order=0: from MSB to LSB
    output [3:0]    o_index
);
    wire [15:0] code_reversal;
    genvar i;
    generate
        for (i = 0; i<16; i=i+1) begin
            assign code_reversal[i] = i_code[15-i];
        end
    endgenerate

    // if need to find from MSB to LSB, use the reversal code, then bit-reverse the index before output
    wire [15:0] code;
    assign code = i_order?i_code:code_reversal;

    // from LSB to MSB find the first 1-bit position of the code
    wire [3:0] index;
    wire [7:0] cmp_result0;
    wire [3:0] cmp_result1;
    wire [1:0] cmp_result2;
    
    assign index[3] = ~(|code[7:0]);
    assign cmp_result0 = index[3]?code[15:8]:code[7:0];
    assign index[2] = ~(|cmp_result0[3:0]);
    assign cmp_result1 = index[2]?cmp_result0[7:4]:cmp_result0[3:0];
    assign index[1] = ~(|cmp_result1[1:0]);
    assign cmp_result2 = index[1]?cmp_result1[3:2]:cmp_result1[1:0];
    assign index[0] = ~cmp_result2[0];

    // output
    assign o_index = i_order?index:(~index);
endmodule