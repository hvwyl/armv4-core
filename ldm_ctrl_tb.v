`timescale 1ns/1ps
module ldm_ctrl_tb ();
reg clk, rst_n;

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    rst_n = 1;
    #10
    rst_n = 0;
    #10
    rst_n = 1;
    #1000
    $finish();
end

reg ldm_vld, p, u, l;
reg [15:0] reglist;
wire hold;
wire flushreq;
wire [3:0] reg_code;
wire mem_vld;
wire [31:0] offset;

integer i;
initial begin
    i <= 0;
    # 10
    forever @ (negedge clk) begin
        if (!hold) begin
            if (i<8) begin
                ldm_vld <= 1'b1;
                p <= $random;
                u <= $random;
                l <= $random;
                reglist <= $random;
                i <= i+1;
            end
            else begin
                ldm_vld <= 1'b0;
            end
        end
        else begin
            ldm_vld <= 1'b0;
        end
    end
end

ldm_ctrl ldm_ctrl_0(
    .clk                (clk),
    .rst_n              (rst_n),
    .en                 (1'b1),

    .i_ldm_vld          (ldm_vld),
    .i_ldm_p            (p),
    .i_ldm_u            (u),
    .i_ldm_l            (l),
    .i_reglist          (reglist),

    .o_ldm_hold         (hold),
    .o_ldm_flushreq     (flushreq),
    .o_ldm_offset       (offset),
    .o_ldm_mem_vld      (mem_vld),
    .o_ldm_reg_code     (reg_code)
);
endmodule