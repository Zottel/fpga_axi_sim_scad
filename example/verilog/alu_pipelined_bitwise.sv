`default_nettype none

module alu_pipelined_bitwise
	#(parameter DATA_WIDTH=32,
		OPCODE_WIDTH = 6,
		ALU_OP_NOP1 = 6'd00,
		ALU_OP_NOP2 = 6'd01,
		ALU_OP_DUP  = 6'd02,
		ALU_OP_SWAP = 6'd03,
		ALU_OP_NOT  = 6'd04,
		ALU_OP_AND  = 6'd05,
		ALU_OP_OR   = 6'd06) (
		input wire clock,
		data_interface.consumer operator,
		data_interface.consumer left,
		data_interface.consumer right,
		data_interface.producer result,
		data_interface.producer overflow);
	
	reg result_valid = 0;
	reg [DATA_WIDTH-1:0] result_data = 0;
	reg overflow_valid = 0;
	reg [DATA_WIDTH-1:0] overflow_data = 0;
	
	assign result.valid = result_valid;
	assign result.data = result_data;
	assign overflow.valid = overflow_valid;
	assign overflow.data = overflow_data;
	
	wire space_for_results;
	assign space_for_results =
		(result.ack || !result_valid) &&
		(overflow.ack || !overflow_valid);
	
	// Which of result and overflow are part of the next result.
	wire next_result_valid;
	wire next_overflow_valid;
	// Values to be written to result and overflow when there is space.
	var [DATA_WIDTH-1:0] next_result;
	var [DATA_WIDTH-1:0] next_overflow;
	
	wire next_results_ready;
	assign next_results_ready = next_result_valid | next_overflow_valid;
	
	always @ (posedge clock) begin
		if (space_for_results && next_results_ready) begin
			result_valid <= next_result_valid;
			overflow_valid <= next_overflow_valid;
			result_data <= next_result;
			overflow_data <= next_overflow;
		end else if (space_for_results) begin
			result_valid   <= 0;
			overflow_valid <= 0;
			result_data   <= 0;
			overflow_data <= 0;
		end
	end
	
	// Connect to combinatorial ALU circuits from alu_simple.
	var consume_right;
	var consume_left;
	var produce_result;
	var produce_overflow;
	wire inputs_ready;
	assign inputs_ready =
		operator.valid &&
		(!consume_left || left.valid) &&
		(!consume_right || right.valid);
	assign next_result_valid = inputs_ready && produce_result;
	assign next_overflow_valid = inputs_ready && produce_overflow;
	assign operator.ack = space_for_results && next_results_ready;
	assign left.ack = consume_left && space_for_results && next_results_ready;
	assign right.ack = consume_right && space_for_results && next_results_ready;
	
	wire [OPCODE_WIDTH-1:0] opcode;
	assign opcode = operator.data[OPCODE_WIDTH-1:0];

	// Combinatorial operations copied from alu_simple.
	always_comb begin
		case (opcode)
			ALU_OP_NOP1: begin
				next_result = left.data;
				next_overflow = 0;
				consume_left = 1;
				consume_right = 0;
				produce_result = 1;
				produce_overflow = 0;
			end
			ALU_OP_NOP2: begin
				next_result = left.data;
				next_overflow = right.data;
				consume_left = 1;
				consume_right = 1;
				produce_result = 1;
				produce_overflow = 1;
			end
			ALU_OP_DUP: begin
				next_result = left.data;
				next_overflow = left.data;
				consume_left = 1;
				consume_right = 0;
				produce_result = 1;
				produce_overflow = 1;
			end
			ALU_OP_SWAP: begin
				next_result = right.data;
				next_overflow = left.data;
				consume_left = 1;
				consume_right = 1;
				produce_result = 1;
				produce_overflow = 1;
			end
			ALU_OP_NOT: begin
				next_result = ~left.data;
				next_overflow = 0;
				consume_left = 1;
				consume_right = 0;
				produce_result = 1;
				produce_overflow = 0;
			end
			ALU_OP_AND: begin
				next_result = left.data & right.data;
				next_overflow = 0;
				consume_left = 1;
				consume_right = 1;
				produce_result = 1;
				produce_overflow = 0;
			end
			ALU_OP_OR: begin
				next_result = left.data | right.data;
				next_overflow = 0;
				consume_left = 1;
				consume_right = 1;
				produce_result = 1;
				produce_overflow = 0;
			end
			default: begin
				next_result = 0;
				next_overflow = 0;
				consume_left = 0;
				consume_right = 0;
				produce_result = 0;
				produce_overflow = 0;
			end
		endcase
	end
endmodule

