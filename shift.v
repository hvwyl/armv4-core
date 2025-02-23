module shift (
    input [1:0]     i_type, // 0: LSL, 1: LSR, 2: ASR, 3: ROR
    input [31:0]    i_op,
    input [4:0]     i_amount,
    input           i_carry,
    output [31:0]   o_result,
    output          o_carry
);
    // 32 bit barrel shifter
    localparam LSL = 2'b00;
    localparam LSR = 2'b01;
    localparam ASR = 2'b10;
    localparam ROR = 2'b11;

    reg [31:0] shift1;
    reg carry1;
    always @(*) begin
        if (i_amount[0]) begin
            case (i_type)
                LSL: begin
                    shift1 = {i_op[30:0], 1'b0};
                    carry1 = i_op[31];
                end
                LSR: begin
                    shift1 = {1'b0, i_op[31:1]};
                    carry1 = i_op[0];
                end
                ASR: begin
                    shift1 = {i_op[31], i_op[31:1]};
                    carry1 = i_op[0];
                end
                ROR: begin
                    shift1 = {i_op[0], i_op[31:1]};
                    carry1 = i_op[0];
                end
            endcase
        end
        else begin
            shift1 = i_op;
            carry1 = i_carry;
        end
    end

    reg [31:0] shift2;
    reg carry2;
    always @(*) begin
        if (i_amount[1]) begin
            case (i_type)
                LSL: begin
                    shift2 = {shift1[29:0], 2'b0};
                    carry2 = shift1[30];
                end
                LSR: begin
                    shift2 = {2'b0, shift1[31:2]};
                    carry2 = shift1[1];
                end
                ASR: begin
                    shift2 = {{2{shift1[31]}}, shift1[31:2]};
                    carry2 = shift1[1];
                end
                ROR: begin
                    shift2 = {shift1[1:0], shift1[31:2]};
                    carry2 = shift1[1];
                end
            endcase
        end
        else begin
            shift2 = shift1;
            carry2 = carry1;
        end
    end

    reg [31:0] shift4;
    reg carry4;
    always @(*) begin
        if (i_amount[2]) begin
            case (i_type)
                LSL: begin
                    shift4 = {shift2[27:0], 4'b0};
                    carry4 = shift2[28];
                end
                LSR: begin
                    shift4 = {4'b0, shift2[31:4]};
                    carry4 = shift2[3];
                end
                ASR: begin
                    shift4 = {{4{shift2[31]}}, shift2[31:4]};
                    carry4 = shift2[3];
                end
                ROR: begin
                    shift4 = {shift2[3:0], shift2[31:4]};
                    carry4 = shift2[3];
                end
            endcase
        end
        else begin
            shift4 = shift2;
            carry4 = carry2;
        end
    end

    reg [31:0] shift8;
    reg carry8;
    always @(*) begin
        if (i_amount[3]) begin
            case (i_type)
                LSL: begin
                    shift8 = {shift4[23:0], 8'b0};
                    carry8 = shift4[24];
                end
                LSR: begin
                    shift8 = {8'b0, shift4[31:8]};
                    carry8 = shift4[7];
                end
                ASR: begin
                    shift8 = {{8{shift4[31]}}, shift4[31:8]};
                    carry8 = shift4[7];
                end
                ROR: begin
                    shift8 = {shift4[7:0], shift4[31:8]};
                    carry8 = shift4[7];
                end
            endcase
        end
        else begin
            shift8 = shift4;
            carry8 = carry4;
        end
    end

    reg [31:0] shift16;
    reg carry16;
    always @(*) begin
        if (i_amount[4]) begin
            case (i_type)
                LSL: begin
                    shift16 = {shift8[15:0], 16'b0};
                    carry16 = shift8[16];
                end
                LSR: begin
                    shift16 = {16'b0, shift8[31:16]};
                    carry16 = shift8[15];
                end
                ASR: begin
                    shift16 = {{16{shift8[31]}}, shift8[31:16]};
                    carry16 = shift8[15];
                end
                ROR: begin
                    shift16 = {shift8[15:0], shift8[31:16]};
                    carry16 = shift8[15];
                end
            endcase
        end
        else begin
            shift16 = shift8;
            carry16 = carry8;
        end
    end

    assign o_result = shift16;
    assign o_carry = carry16;
endmodule