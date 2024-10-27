`timescale 10ns/1ps
/*
    ARMv4-core TestBench
    
    Please run 'armbuild' first！
    ```
    cd ./armbuild
    make
    ```
*/

`define TB_RAM_SIZE 65536   // size of ram (unit in byte)
`define TB_RAM_FILE "armbuild/build.txt"

`include "def.v"
module armv4core_tb ();
reg clk, rst_n, en, irq;
reg [31:0] irq_r0, irq_r1;

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
    #40000
    $finish();
end

initial begin
    en = 1;
    #1000
    en = 0;
    #1000
    en = 1;
end

initial begin
    irq = 0;
    #6000
    irq_r0 = 32'h01234567;
    irq_r1 = 32'h89ABCDEF;
    irq = 1;
    #100
    irq = 0;
    #6000
    irq_r0 = 32'hFEDCBA98;
    irq_r1 = 32'h76543210;
    irq = 1;
    #100
    irq = 0;
    #6000
    irq_r0 = 32'h01234567;
    irq_r1 = 32'h89ABCDEF;
    irq = 1;
    #100
    irq = 0;
end

reg [7:0] ram [`TB_RAM_SIZE-1:0];

/* load ram from file */
initial begin
    $readmemh(`TB_RAM_FILE, ram, 'h0000_0000);
end

`define DELAY 2

/* rom interface */
wire rom_en;
wire [31:0] rom_addr;
reg [31:0] rom_data;
always @(posedge clk) begin
    if (rom_en) begin
        rom_data <= #`DELAY {ram[rom_addr+3], ram[rom_addr+2], ram[rom_addr+1], ram[rom_addr]};
    end
end

/* ram interface */
wire ram_en;
wire ram_wr;
wire [1:0] ram_size;
wire [31:0] ram_addr;
wire [31:0] ram_wdata;
reg [31:0] ram_rdata;
always @(posedge clk) begin
    if (ram_en) begin
        if (ram_wr) begin
            case (ram_size)
                `MEM_B: begin
                    ram[ram_addr] <= ram_wdata[7:0];
                end
                `MEM_H: begin
                    ram[ram_addr] <= ram_wdata[7:0];
                    ram[ram_addr+1] <= ram_wdata[15:8];
                end
                default: begin
                    ram[ram_addr] <= ram_wdata[7:0];
                    ram[ram_addr+1] <= ram_wdata[15:8];
                    ram[ram_addr+2] <= ram_wdata[23:16];
                    ram[ram_addr+3] <= ram_wdata[31:24];
                end
            endcase
        end
        else begin
            case (ram_size)
                `MEM_B: begin
                    ram_rdata <= #`DELAY {24'b0, ram[ram_addr]};
                end
                `MEM_H: begin
                    ram_rdata <= #`DELAY {16'b0, ram[ram_addr+1], ram[ram_addr]};
                end
                default: begin
                    ram_rdata <= #`DELAY {ram[ram_addr+3], ram[ram_addr+2], ram[ram_addr+1], ram[ram_addr]};
                end
            endcase
        end
    end
end

armv4core armv4core_0(
    .clk                (clk),
    .rst_n              (rst_n),
    .en                 (en),

    /* interrupt request */
    .i_irq              (irq),
    .i_irq_r0           (irq_r0),
    .i_irq_r1           (irq_r1),

    /* rom bus */
    .o_rom_en           (rom_en),
    .o_rom_addr         (rom_addr),
    .i_rom_data         (rom_data),

    /* ram bus */
    .o_ram_en           (ram_en),
    .o_ram_wr           (ram_wr),
    .o_ram_size         (ram_size),
    .o_ram_addr         (ram_addr),
    .i_ram_rdata        (ram_rdata),
    .o_ram_wdata        (ram_wdata)
);
endmodule
