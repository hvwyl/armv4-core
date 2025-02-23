module shift_tb ();
localparam NUM = 20;

reg [31:0] op;
reg [4:0] amount;
reg carryin;

wire [31:0] lsl_result;
wire lsl_carryout;
wire [31:0] lsl_result_ref;
wire lsl_carryout_ref;
wire lsl_pass;
assign {lsl_carryout_ref, lsl_result_ref} = {carryin, op} << amount;
assign lsl_pass = ({lsl_result, lsl_carryout}=={lsl_result_ref, lsl_carryout_ref});

wire [31:0] lsr_result;
wire lsr_carryout;
wire [31:0] lsr_result_ref;
wire lsr_carryout_ref;
wire lsr_pass;
assign {lsr_result_ref, lsr_carryout_ref} = {op, carryin} >> amount;
assign lsr_pass = ({lsr_result, lsr_carryout}=={lsr_result_ref, lsr_carryout_ref});

wire [31:0] asr_result;
wire asr_carryout;
wire [31:0] asr_result_ref;
wire asr_carryout_ref;
wire asr_pass;
assign {asr_result_ref, asr_carryout_ref} = $signed({op, carryin}) >>> amount;
assign asr_pass = ({asr_result, asr_carryout}=={asr_result_ref, asr_carryout_ref});

wire [31:0] ror_result;
wire ror_carryout;
wire [31:0] ror_result_ref;
wire ror_carryout_ref;
wire ror_pass;
assign ror_result_ref = (op>>amount)|(op<<(32-amount));
assign ror_carryout_ref = (amount==0)?carryin:ror_result_ref[31];
assign ror_pass = ({ror_result, ror_carryout}=={ror_result_ref, ror_carryout_ref});

wire pass;
assign pass = lsl_pass & lsr_pass & asr_pass & ror_pass;

initial begin
    repeat (NUM) begin
        #10
        op <= $random;
        amount <= $random;
        carryin <= $random;
    end
    $finish;
end

localparam LSL = 2'b00;
localparam LSR = 2'b01;
localparam ASR = 2'b10;
localparam ROR = 2'b11;

// LSL module
shift shift_lsl (
    .i_type     (LSL),
    .i_op       (op),
    .i_amount   (amount),
    .i_carry    (carryin),
    .o_result   (lsl_result),
    .o_carry    (lsl_carryout)
);

// LSR module
shift shift_lsr (
    .i_type     (LSR),
    .i_op       (op),
    .i_amount   (amount),
    .i_carry    (carryin),
    .o_result   (lsr_result),
    .o_carry    (lsr_carryout)
);

// ASR module
shift shift_asr (
    .i_type     (ASR),
    .i_op       (op),
    .i_amount   (amount),
    .i_carry    (carryin),
    .o_result   (asr_result),
    .o_carry    (asr_carryout)
);

// ROR module
shift shift_ror (
    .i_type     (ROR),
    .i_op       (op),
    .i_amount   (amount),
    .i_carry    (carryin),
    .o_result   (ror_result),
    .o_carry    (ror_carryout)
);
endmodule