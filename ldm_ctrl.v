module ldm_ctrl (
    input clk,
    input rst_n,
    input en,

    input               i_ldm_vld,
    input               i_ldm_p,    // P=0:A(After)     P=1:B(Before)
    input               i_ldm_u,    // U=0:D(Decrement) U=1:I(Increment)
    input               i_ldm_s,    // S=0:None         S=1:Exception Return
    input               i_ldm_l,    // L=0:W(Write)     L=1:R(Read)
    input [15:0]        i_reglist,

    output              o_spsr_res,

    output              o_ldm_hold,
    output              o_ldm_flushreq,
    output [31:0]       o_ldm_offset,
    output              o_ldm_mem_vld,
    output [3:0]        o_ldm_reg_code
);
    reg ldm_p;
    reg ldm_u;
    reg ldm_s;
    reg lpc_flag;
    reg [15:0] reglist_reg;

    wire [3:0] reg_code;
    reg [3:0] reg_code_past;

    one_detector one_detector_0(
        .i_code     (reglist_reg),
        .i_order    (ldm_u),
        .o_index    (reg_code)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_code_past <= 'b0;
        end
        else if (en) begin
            reg_code_past <= reg_code;
        end
    end

    reg [4:0] cnt;

    assign o_spsr_res = lpc_flag & (reglist_reg=='b0) & ldm_s;
    assign o_ldm_hold = ~(reglist_reg=='b0);
    assign o_ldm_flushreq = lpc_flag & (reglist_reg=='b0);
    assign o_ldm_offset = {25'd0, cnt, 2'd0};
    assign o_ldm_mem_vld = ldm_p?(cnt!='b0):(reglist_reg!='b0);
    assign o_ldm_reg_code = ldm_p?reg_code_past:reg_code;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 'd0;
            ldm_p <= 'b0;
            ldm_u <= 'b0;
            ldm_s <= 'b0;
            reglist_reg <= 'b0;
            lpc_flag <= 'b0;
        end
        else if (en) begin
            if (reglist_reg=='b0) begin
                cnt <= 'd0;
                ldm_p <= i_ldm_p;
                ldm_u <= i_ldm_u;
                ldm_s <= i_ldm_s;
                if (i_ldm_vld) begin
                    reglist_reg <= i_reglist;
                    lpc_flag <= i_ldm_l & i_reglist[15]; // load PC register, need to flush pipeline
                end
                else begin
                    reglist_reg <= 'b0;
                    lpc_flag <= 'b0;
                end
            end
            else begin
                case (cnt[3:0])
                    'd0: cnt <= 'd1;
                    'd1: cnt <= 'd2;
                    'd2: cnt <= 'd3;
                    'd3: cnt <= 'd4;
                    'd4: cnt <= 'd5;
                    'd5: cnt <= 'd6;
                    'd6: cnt <= 'd7;
                    'd7: cnt <= 'd8;
                    'd8: cnt <= 'd9;
                    'd9: cnt <= 'd10;
                    'd10: cnt <= 'd11;
                    'd11: cnt <= 'd12;
                    'd12: cnt <= 'd13;
                    'd13: cnt <= 'd14;
                    'd14: cnt <= 'd15;
                    'd15: cnt <= 'd16;
                endcase
                reglist_reg[reg_code] <= 'b0;
            end
        end
    end
endmodule