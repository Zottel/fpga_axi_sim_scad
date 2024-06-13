`default_nettype none

module alu_pipelined_toomcook
	#(parameter DATA_WIDTH=32,
		OPFIFO_DEPTH = 6,
		OPCODE_WIDTH = 6,
		ALU_OP_NOP1 = 6'd00,
		ALU_OP_NOP2 = 6'd01,
		ALU_OP_DUP  = 6'd02,
		ALU_OP_SWAP = 6'd03,
		ALU_OP_NOT  = 6'd04,
		ALU_OP_AND  = 6'd05,
		ALU_OP_OR   = 6'd06,
		ALU_OP_EQQ  = 6'd07,
		ALU_OP_NEQ  = 6'd08,
		ALU_OP_ADDN = 6'd09,
		ALU_OP_ADDZ = 6'd10,
		ALU_OP_SUBN = 6'd11,
		ALU_OP_SUBZ = 6'd12,
		ALU_OP_LESN = 6'd13,
		ALU_OP_LESZ = 6'd14,
		ALU_OP_LEQN = 6'd15,
		ALU_OP_LEQZ = 6'd16,
		ALU_OP_MUL  = 6'd17,
		ALU_OP_DIVN = 6'd18,
		ALU_OP_DIVZ = 6'd19) (
		input wire clock,
		data_interface.consumer operator,
		data_interface.consumer left,
		data_interface.consumer right,
		data_interface.producer result,
		data_interface.producer overflow);
	
	// BitWise ALU
	data_interface #(.DATA_WIDTH(DATA_WIDTH)) bitwise_op();
	data_interface #(.DATA_WIDTH(DATA_WIDTH)) bitwise_left();
	data_interface #(.DATA_WIDTH(DATA_WIDTH)) bitwise_right();
	data_interface #(.DATA_WIDTH(DATA_WIDTH)) bitwise_result();
	data_interface #(.DATA_WIDTH(DATA_WIDTH)) bitwise_overflow();
	alu_pipelined_bitwise
	#(.DATA_WIDTH(DATA_WIDTH),
		.OPCODE_WIDTH(OPCODE_WIDTH),
		.ALU_OP_NOP1(ALU_OP_NOP1),
		.ALU_OP_NOP2(ALU_OP_NOP2),
		.ALU_OP_DUP(ALU_OP_DUP),
		.ALU_OP_SWAP(ALU_OP_SWAP),
		.ALU_OP_NOT(ALU_OP_NOT),
		.ALU_OP_AND(ALU_OP_AND),
		.ALU_OP_OR(ALU_OP_OR))
	bitwise(
		.clock(clock),
		.operator(bitwise_op),
		.left(bitwise_left),
		.right(bitwise_right),
		.result(bitwise_result),
		.overflow(bitwise_overflow)
	);
	
	// Addition/Subtraction
	data_interface #(.DATA_WIDTH(DATA_WIDTH)) adder_op();
	data_interface #(.DATA_WIDTH(DATA_WIDTH)) adder_left();
	data_interface #(.DATA_WIDTH(DATA_WIDTH)) adder_right();
	data_interface #(.DATA_WIDTH(DATA_WIDTH)) adder_result();
	data_interface #(.DATA_WIDTH(DATA_WIDTH)) adder_overflow();
	alu_pipelined_adder
	#(.DATA_WIDTH(DATA_WIDTH),
		.OPCODE_WIDTH(OPCODE_WIDTH),
		.ALU_OP_EQQ(ALU_OP_EQQ),
		.ALU_OP_NEQ(ALU_OP_NEQ),
		.ALU_OP_ADDN(ALU_OP_ADDN),
		.ALU_OP_ADDZ(ALU_OP_ADDZ),
		.ALU_OP_SUBN(ALU_OP_SUBN),
		.ALU_OP_SUBZ(ALU_OP_SUBZ),
		.ALU_OP_LESN(ALU_OP_LESN),
		.ALU_OP_LESZ(ALU_OP_LESZ),
		.ALU_OP_LEQN(ALU_OP_LEQN),
		.ALU_OP_LEQZ(ALU_OP_LEQZ))
	adder(
		.clock(clock),
		.operator(adder_op),
		.left(adder_left),
		.right(adder_right),
		.result(adder_result),
		.overflow(adder_overflow)
	);
	
	// Multiplication
	data_interface #(.DATA_WIDTH(DATA_WIDTH)) mult_op();
	data_interface #(.DATA_WIDTH(DATA_WIDTH)) mult_left();
	data_interface #(.DATA_WIDTH(DATA_WIDTH)) mult_right();
	data_interface #(.DATA_WIDTH(DATA_WIDTH)) mult_result();
	data_interface #(.DATA_WIDTH(DATA_WIDTH)) mult_overflow();
	alu_pipelined_mult_toomcook
	#(.DATA_WIDTH(DATA_WIDTH),
		.OPCODE_WIDTH(OPCODE_WIDTH),
		.ALU_OP_MUL(ALU_OP_MUL))
	mult(
		.clock(clock),
		.operator(mult_op),
		.left(mult_left),
		.right(mult_right),
		.result(mult_result),
		.overflow(mult_overflow)
	);
	
	// Divider
	data_interface #(.DATA_WIDTH(DATA_WIDTH)) div_op();
	data_interface #(.DATA_WIDTH(DATA_WIDTH)) div_left();
	data_interface #(.DATA_WIDTH(DATA_WIDTH)) div_right();
	data_interface #(.DATA_WIDTH(DATA_WIDTH)) div_result();
	data_interface #(.DATA_WIDTH(DATA_WIDTH)) div_overflow();
	alu_pipelined_div
	#(.DATA_WIDTH(DATA_WIDTH),
		.OPCODE_WIDTH(OPCODE_WIDTH),
		.ALU_OP_DIVN(ALU_OP_DIVN),
		.ALU_OP_DIVZ(ALU_OP_DIVZ))
	div(
		.clock(clock),
		.operator(div_op),
		.left(div_left),
		.right(div_right),
		.result(div_result),
		.overflow(div_overflow)
	);
	
	data_interface #(.DATA_WIDTH(DATA_WIDTH)) op_to_demux();
	data_interface #(.DATA_WIDTH(DATA_WIDTH)) op_to_opfifo();
	data_interface #(.DATA_WIDTH(DATA_WIDTH)) op_from_opfifo();
	fifo_pointers #(.WIDTH(DATA_WIDTH), .DEPTH(OPFIFO_DEPTH))
	opfifo(
		.clock(clock),
		.in(op_to_opfifo.data),
		.in_valid(op_to_opfifo.valid),
		.in_ack(op_to_opfifo.ack),
		.out(op_from_opfifo.data),
		.out_valid(op_from_opfifo.valid),
		.out_ack(op_from_opfifo.ack)
	);
	
	// Connect operator input to demux and operator-order FIFO.
	// It must only be consumed when the demux and FIFO are ready.
	assign operator.ack = op_to_demux.ack && op_to_opfifo.ack;
	assign op_to_demux.valid = operator.valid && op_to_opfifo.ack;
	assign op_to_opfifo.valid = operator.valid && op_to_demux.ack;
	assign op_to_demux.data = operator.data;
	assign op_to_opfifo.data = operator.data;
	
	wire [OPCODE_WIDTH-1:0] input_opcode;
	assign input_opcode = op_to_demux.data[OPCODE_WIDTH-1:0];
	
	// Demultiplexer for component inputs.
	always_comb begin
		case (input_opcode)
			ALU_OP_NOP1, ALU_OP_NOP2,
			ALU_OP_DUP, ALU_OP_SWAP,
			ALU_OP_NOT,
			ALU_OP_AND,
			ALU_OP_OR: begin
				bitwise_op.valid = op_to_demux.valid;
				bitwise_op.data = op_to_demux.data;
				op_to_demux.ack = bitwise_op.ack;
				bitwise_left.valid = left.valid;
				bitwise_left.data = left.data;
				left.ack = bitwise_left.ack;
				bitwise_right.valid = right.valid;
				bitwise_right.data = right.data;
				right.ack = bitwise_right.ack;
				
				adder_op.valid = 0; adder_op.data = 0;
				adder_left.valid = 0; adder_left.data = 0;
				adder_right.valid = 0; adder_right.data = 0;
				
				mult_op.valid = 0; mult_op.data = 0;
				mult_left.valid = 0; mult_left.data = 0;
				mult_right.valid = 0; mult_right.data = 0;
				
				div_op.valid = 0; div_op.data = 0;
				div_left.valid = 0; div_left.data = 0;
				div_right.valid = 0; div_right.data = 0;
			end
			
			ALU_OP_EQQ, ALU_OP_NEQ,
			ALU_OP_ADDN, ALU_OP_ADDZ,
			ALU_OP_SUBN, ALU_OP_SUBZ,
			ALU_OP_LESN, ALU_OP_LESZ,
			ALU_OP_LEQN, ALU_OP_LEQZ: begin
				bitwise_op.valid = 0; bitwise_op.data = 0;
				bitwise_left.valid = 0; bitwise_left.data = 0;
				bitwise_right.valid = 0; bitwise_right.data = 0;
				
				adder_op.valid = op_to_demux.valid;
				adder_op.data = op_to_demux.data;
				op_to_demux.ack = adder_op.ack;
				adder_left.valid = left.valid;
				adder_left.data = left.data;
				left.ack = adder_left.ack;
				adder_right.valid = right.valid;
				adder_right.data = right.data;
				right.ack = adder_right.ack;
				
				mult_op.valid = 0; mult_op.data = 0;
				mult_left.valid = 0; mult_left.data = 0;
				mult_right.valid = 0; mult_right.data = 0;
				
				div_op.valid = 0; div_op.data = 0;
				div_left.valid = 0; div_left.data = 0;
				div_right.valid = 0; div_right.data = 0;
			end
			
			ALU_OP_MUL: begin
				bitwise_op.valid = 0; bitwise_op.data = 0;
				bitwise_left.valid = 0; bitwise_left.data = 0;
				bitwise_right.valid = 0; bitwise_right.data = 0;
				
				adder_op.valid = 0; adder_op.data = 0;
				adder_left.valid = 0; adder_left.data = 0;
				adder_right.valid = 0; adder_right.data = 0;
				
				mult_op.valid = op_to_demux.valid;
				mult_op.data = op_to_demux.data;
				op_to_demux.ack = mult_op.ack;
				mult_left.valid = left.valid;
				mult_left.data = left.data;
				left.ack = mult_left.ack;
				mult_right.valid = right.valid;
				mult_right.data = right.data;
				right.ack = mult_right.ack;
				
				div_op.valid = 0; div_op.data = 0;
				div_left.valid = 0; div_left.data = 0;
				div_right.valid = 0; div_right.data = 0;
			end
			
			ALU_OP_DIVN, ALU_OP_DIVZ: begin
				bitwise_op.valid = 0; bitwise_op.data = 0;
				bitwise_left.valid = 0; bitwise_left.data = 0;
				bitwise_right.valid = 0; bitwise_right.data = 0;
				
				adder_op.valid = 0; adder_op.data = 0;
				adder_left.valid = 0; adder_left.data = 0;
				adder_right.valid = 0; adder_right.data = 0;
				
				mult_op.valid = 0; mult_op.data = 0;
				mult_left.valid = 0; mult_left.data = 0;
				mult_right.valid = 0; mult_right.data = 0;
				
				div_op.valid = op_to_demux.valid;
				div_op.data = op_to_demux.data;
				op_to_demux.ack = div_op.ack;
				div_left.valid = left.valid;
				div_left.data = left.data;
				left.ack = div_left.ack;
				div_right.valid = right.valid;
				div_right.data = right.data;
				right.ack = div_right.ack;
			end			
			default: begin
				op_to_demux.ack = 0; left.ack = 0; right.ack = 0;
				
				bitwise_op.valid = 0; bitwise_op.data = 0;
				bitwise_left.valid = 0; bitwise_left.data = 0;
				bitwise_right.valid = 0; bitwise_right.data = 0;
				
				adder_op.valid = 0; adder_op.data = 0;
				adder_left.valid = 0; adder_left.data = 0;
				adder_right.valid = 0; adder_right.data = 0;
				
				mult_op.valid = 0; mult_op.data = 0;
				mult_left.valid = 0; mult_left.data = 0;
				mult_right.valid = 0; mult_right.data = 0;
				
				div_op.valid = 0; div_op.data = 0;
				div_left.valid = 0; div_left.data = 0;
				div_right.valid = 0; div_right.data = 0;
			end
		endcase
	end
	
	wire [OPCODE_WIDTH-1:0] output_opcode;
	assign output_opcode = op_from_opfifo.data[OPCODE_WIDTH-1:0];
	wire [(DATA_WIDTH-OPCODE_WIDTH)-1:0] output_count;
	assign output_count = op_from_opfifo.data[(DATA_WIDTH-1):OPCODE_WIDTH];
	
	data_interface #(.DATA_WIDTH(DATA_WIDTH)) mux_result();
	data_interface #(.DATA_WIDTH(DATA_WIDTH)) mux_overflow();
	
	// Demultiplexer for component inputs.
	always_comb begin
		case (output_opcode)
			ALU_OP_NOP1, ALU_OP_NOP2,
			ALU_OP_DUP, ALU_OP_SWAP,
			ALU_OP_NOT,
			ALU_OP_AND,
			ALU_OP_OR: begin
				mux_result.valid = bitwise_result.valid;
				mux_result.data = bitwise_result.data;
				bitwise_result.ack = mux_result.ack;
				mux_overflow.valid = bitwise_overflow.valid;
				mux_overflow.data = bitwise_overflow.data;
				bitwise_overflow.ack = mux_overflow.ack;
				
				adder_result.ack = 0; adder_overflow.ack = 0;
				mult_result.ack = 0; mult_overflow.ack = 0;
				div_result.ack = 0; div_overflow.ack = 0;
			end
			
			ALU_OP_EQQ, ALU_OP_NEQ,
			ALU_OP_ADDN, ALU_OP_ADDZ,
			ALU_OP_SUBN, ALU_OP_SUBZ,
			ALU_OP_LESN, ALU_OP_LESZ,
			ALU_OP_LEQN, ALU_OP_LEQZ: begin
				mux_result.valid = adder_result.valid;
				mux_result.data = adder_result.data;
				adder_result.ack = mux_result.ack;
				mux_overflow.valid = adder_overflow.valid;
				mux_overflow.data = adder_overflow.data;
				adder_overflow.ack = mux_overflow.ack;
				
				bitwise_result.ack = 0; bitwise_overflow.ack = 0;
				mult_result.ack = 0; mult_overflow.ack = 0;
				div_result.ack = 0; div_overflow.ack = 0;
			end
			
			ALU_OP_MUL: begin
				mux_result.valid = mult_result.valid;
				mux_result.data = mult_result.data;
				mult_result.ack = mux_result.ack;
				mux_overflow.valid = mult_overflow.valid;
				mux_overflow.data = mult_overflow.data;
				mult_overflow.ack = mux_overflow.ack;
				
				bitwise_result.ack = 0; bitwise_overflow.ack = 0;
				adder_result.ack = 0; adder_overflow.ack = 0;
				div_result.ack = 0; div_overflow.ack = 0;
			end
			
			ALU_OP_DIVN, ALU_OP_DIVZ: begin
				mux_result.valid = div_result.valid;
				mux_result.data = div_result.data;
				div_result.ack = mux_result.ack;
				mux_overflow.valid = div_overflow.valid;
				mux_overflow.data = div_overflow.data;
				div_overflow.ack = mux_overflow.ack;
				
				bitwise_result.ack = 0; bitwise_overflow.ack = 0;
				adder_result.ack = 0; adder_overflow.ack = 0;
				mult_result.ack = 0; mult_overflow.ack = 0;
			end
			
			default: begin
				mux_result.valid = 0; mux_result.data = 0;
				mux_overflow.valid = 0; mux_overflow.data = 0;
				
				bitwise_result.ack = 0; bitwise_overflow.ack = 0;
				adder_result.ack = 0; adder_overflow.ack = 0;
				mult_result.ack = 0; mult_overflow.ack = 0;
				div_result.ack = 0; div_overflow.ack = 0;
			end
		endcase
	end
	
	// The inputs of modules that then produce multiple copies
	// of our output data.
	data_interface #(.DATA_WIDTH(DATA_WIDTH)) result_to_copy();
	data_interface #(.DATA_WIDTH(DATA_WIDTH)) overflow_to_copy();
	
	// Operation output is transferred in one cycle when:
	// - There is either a valid result or overflow.
	// - There is an operation available for which output may be read.
	// - There is enough space in the following output stage.
	//   (Probably the copies modules.)
	wire output_data_ready;
	assign output_data_ready = mux_result.valid || mux_overflow.valid;
	wire output_space_ready;
	assign output_space_ready =
		(!mux_result.valid || result_to_copy.ack) &&
		(!mux_overflow.valid || overflow_to_copy.ack);
	assign mux_result.ack = op_from_opfifo.valid && output_space_ready;
	assign mux_overflow.ack = op_from_opfifo.valid && output_space_ready;
	assign op_from_opfifo.ack =
		op_from_opfifo.valid && output_data_ready && output_space_ready;
	
	assign result_to_copy.valid = mux_result.valid && output_space_ready;
	assign result_to_copy.data = mux_result.data;
	assign overflow_to_copy.valid = mux_overflow.valid && output_space_ready;
	assign overflow_to_copy.data = mux_overflow.data;
	
	copies #(.DATA_WIDTH(DATA_WIDTH),.COUNT_WIDTH(DATA_WIDTH-OPCODE_WIDTH))
		result_to_copy_module(
		.clock(clock),
		.in_count(output_count),
		.in(result_to_copy),
		.out(result)
	);
	
	copies #(.DATA_WIDTH(DATA_WIDTH),.COUNT_WIDTH(DATA_WIDTH-OPCODE_WIDTH))
		overflow_to_copy_module(
		.clock(clock),
		.in_count(output_count),
		.in(overflow_to_copy),
		.out(overflow)
	);
	
	
	`ifdef FORMAL
	reg [31:0] cycle = 0;
	always @ (posedge clock) begin
		cycle <= cycle + 1;
	end
	`endif
	
endmodule


