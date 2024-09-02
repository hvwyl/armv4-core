`timescale 1ns/1ps
module one_detector_tb ();
initial begin
    #1000 $finish;
end
reg [15:0] code;
reg order;
wire [3:0] index;
reg [3:0] index_i_ref, index_d_ref;
reg pass;
always @(*) begin
    case (order)
        'b0: pass = (index==index_d_ref);
        'b1: pass = (index==index_i_ref);
    endcase
end

always @(*) begin
    casex (code)
        16'bxxxx_xxxx_xxxx_xxx1: index_i_ref = 4'd0;
        16'bxxxx_xxxx_xxxx_xx10: index_i_ref = 4'd1;
        16'bxxxx_xxxx_xxxx_x100: index_i_ref = 4'd2;
        16'bxxxx_xxxx_xxxx_1000: index_i_ref = 4'd3;
        16'bxxxx_xxxx_xxx1_0000: index_i_ref = 4'd4;
        16'bxxxx_xxxx_xx10_0000: index_i_ref = 4'd5;
        16'bxxxx_xxxx_x100_0000: index_i_ref = 4'd6;
        16'bxxxx_xxxx_1000_0000: index_i_ref = 4'd7;
        16'bxxxx_xxx1_0000_0000: index_i_ref = 4'd8;
        16'bxxxx_xx10_0000_0000: index_i_ref = 4'd9;
        16'bxxxx_x100_0000_0000: index_i_ref = 4'd10;
        16'bxxxx_1000_0000_0000: index_i_ref = 4'd11;
        16'bxxx1_0000_0000_0000: index_i_ref = 4'd12;
        16'bxx10_0000_0000_0000: index_i_ref = 4'd13;
        16'bx100_0000_0000_0000: index_i_ref = 4'd14;
        16'b1000_0000_0000_0000: index_i_ref = 4'd15;
        default: index_i_ref = 4'd15;
    endcase
    casex (code)
        16'b0000_0000_0000_0001: index_d_ref = 4'd0;
        16'b0000_0000_0000_001x: index_d_ref = 4'd1;
        16'b0000_0000_0000_01xx: index_d_ref = 4'd2;
        16'b0000_0000_0000_1xxx: index_d_ref = 4'd3;
        16'b0000_0000_0001_xxxx: index_d_ref = 4'd4;
        16'b0000_0000_001x_xxxx: index_d_ref = 4'd5;
        16'b0000_0000_01xx_xxxx: index_d_ref = 4'd6;
        16'b0000_0000_1xxx_xxxx: index_d_ref = 4'd7;
        16'b0000_0001_xxxx_xxxx: index_d_ref = 4'd8;
        16'b0000_001x_xxxx_xxxx: index_d_ref = 4'd9;
        16'b0000_01xx_xxxx_xxxx: index_d_ref = 4'd10;
        16'b0000_1xxx_xxxx_xxxx: index_d_ref = 4'd11;
        16'b0001_xxxx_xxxx_xxxx: index_d_ref = 4'd12;
        16'b001x_xxxx_xxxx_xxxx: index_d_ref = 4'd13;
        16'b01xx_xxxx_xxxx_xxxx: index_d_ref = 4'd14;
        16'b1xxx_xxxx_xxxx_xxxx: index_d_ref = 4'd15;
        default: index_d_ref = 4'd0;
    endcase
end

initial begin
    forever begin
        order = 0;
        repeat (10) begin
            #10
            code <= $random;
        end
        order = 1;
        repeat (10) begin
            #10
            code <= $random;
        end
    end
end

one_detector one_detector_0(
    .i_code     (code),
    .i_order    (order),
    .o_index    (index)
);
endmodule