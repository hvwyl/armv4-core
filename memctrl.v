`include "def.v"
module memctrl (
    input clk,
    input rst_n,
    input en,

    input               i_memctrl_vld,
    input               i_memctrl_wr,
    input               i_memctrl_sign,
    input [1:0]         i_memctrl_size,
    input [31:0]        i_memctrl_addr,
    output reg [31:0]   o_memctrl_rdata,
    input [31:0]        i_memctrl_wdata,

    output              o_ram_en,
    output              o_ram_wr,
    output [1:0]        o_ram_size,
    output [31:0]       o_ram_addr,
    input [31:0]        i_ram_rdata,
    output [31:0]       o_ram_wdata
);
    reg memctrl_sign;
    reg [1:0] memctrl_size;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            memctrl_sign <= 'b0;
            memctrl_size <= 'b0;
        end
        else if (en) begin
            memctrl_sign <= i_memctrl_sign;
            memctrl_size <= i_memctrl_size;
        end
    end

    /* output */
    assign o_ram_en = i_memctrl_vld;
    assign o_ram_wr = i_memctrl_wr;
    assign o_ram_size = i_memctrl_size;
    assign o_ram_addr = i_memctrl_addr;
    always @(*) begin
        if (memctrl_sign) begin
            case (memctrl_size)
                `MEM_B: o_memctrl_rdata = {{24{i_ram_rdata[7]}} ,i_ram_rdata[7:0]};
                `MEM_H: o_memctrl_rdata = {{16{i_ram_rdata[15]}} ,i_ram_rdata[15:0]};
                default: o_memctrl_rdata = i_ram_rdata;
            endcase
        end
        else begin
            o_memctrl_rdata = i_ram_rdata;
        end
    end
    assign o_ram_wdata = i_memctrl_wdata;
endmodule