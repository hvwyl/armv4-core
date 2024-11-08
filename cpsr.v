module cpsr (
    input clk,
    input rst_n,
    input en,

    input               i_spsr_bak,
    input               i_spsr_res,

    output              o_int_mode,
    output              o_irq_mask,

    input               i_nzcv_flag,
    input [3:0]         i_nzcv_alu,

    output [3:0]        o_nzcv,
    output [3:0]        o_nzcv_next,

    /*
        xPSR (Program Status Registers) definitions
        +----+----+----+----+--------------+----+--------------+----+----+
        | 31 | 30 | 29 | 28 | 27        8  | 7  | 6         2  | 1  | 0  |
        +----+----+----+----+--------------+----+--------------+----+----+
        | N  | Z  | C  | V  | Reserved     | I  | 5'b10100     | M  | 0  |
        +----+----+----+----+--------------+----+--------------+----+----+
    */
    input               i_xpsr_en_ex,
    input               i_xpsr_sel, // S=0: CPSR, S=1: SPSR
    input [31:0]        i_xpsr_reg,
    output [31:0]       o_xpsr_reg
);
    wire write_cpsr;
    assign write_cpsr = ({i_xpsr_en_ex, i_xpsr_sel} == 2'b10);
    wire write_spsr;
    assign write_spsr = ({i_xpsr_en_ex, i_xpsr_sel} == 2'b11);

    reg int_mode;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            int_mode <= 'b0;
        end
        else if (en) begin
            case ({i_spsr_bak, i_spsr_res})
                2'b00: int_mode <= int_mode;
                2'b01: int_mode <= 'b0;
                2'b10: int_mode <= 'b1;
                2'b11: int_mode <= 'b1;
            endcase
        end
    end
    assign o_int_mode = int_mode;

    reg irq_mask;
    reg irq_mask_spsr;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            irq_mask <= 'b1;
            irq_mask_spsr <= 'b1;
        end
        else if (en) begin
            if (i_spsr_res) begin
                irq_mask <= irq_mask_spsr;
            end
            else if (i_spsr_bak) begin
                irq_mask <= 'b1;
            end
            else if (write_cpsr) begin
                irq_mask <= i_xpsr_reg[7];
            end
            if (i_spsr_bak) begin
                irq_mask_spsr <= write_cpsr?i_xpsr_reg[7]:irq_mask;
            end
            else if (write_spsr) begin
                irq_mask_spsr <= i_xpsr_reg[7];
            end
        end
    end
    assign o_irq_mask = irq_mask;

    reg [3:0] nzcv;
    reg [3:0] nzcv_next;
    always @(*) begin
        case ({i_nzcv_flag, write_cpsr})
            2'b00: nzcv_next = nzcv;
            2'b01: nzcv_next = i_xpsr_reg[31:28];
            2'b10: nzcv_next = i_nzcv_alu;
            2'b11: nzcv_next = i_xpsr_reg[31:28];
        endcase
    end
    reg [3:0] nzcv_spsr;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            nzcv <= 4'b0000;
            nzcv_spsr <= 4'b0000; 
        end
        else if (en) begin
            if (i_spsr_res) begin
                nzcv <= nzcv_spsr;
            end
            else begin
                nzcv <= nzcv_next;
            end
            if (i_spsr_bak) begin
                nzcv_spsr <= nzcv_next;
            end
            else if (write_spsr) begin
                nzcv_spsr <= i_xpsr_reg[31:28];
            end
        end
    end
    assign o_nzcv = nzcv;
    assign o_nzcv_next = nzcv_next;

    wire [31:0] cpsr_reg;
    wire [31:0] spsr_reg;
    assign cpsr_reg = {nzcv, 20'b0, irq_mask, 5'b10100, int_mode, 1'b0};
    assign spsr_reg = {nzcv_spsr, 20'b0, irq_mask_spsr, 5'b10100, int_mode, 1'b0};

    assign o_xpsr_reg = i_xpsr_sel?spsr_reg:cpsr_reg;
endmodule