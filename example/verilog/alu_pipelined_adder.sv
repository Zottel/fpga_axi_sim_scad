`default_nettype none

module alu_pipelined_adder
	#(parameter DATA_WIDTH=32,
		OPCODE_WIDTH = 6,
		ALU_OP_EQQ  = 6'd06,
		ALU_OP_NEQ  = 6'd07,
		ALU_OP_ADDN = 6'd08,
		ALU_OP_ADDZ = 6'd09,
		ALU_OP_SUBN = 6'd10,
		ALU_OP_SUBZ = 6'd11,
		ALU_OP_LESN = 6'd12,
		ALU_OP_LESZ = 6'd13,
		ALU_OP_LEQN = 6'd14,
		ALU_OP_LEQZ = 6'd15) (
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
	wire [(2*DATA_WIDTH)-1:0] extended_left;
	assign extended_left = {{DATA_WIDTH{left.data[DATA_WIDTH-1]}},left.data};
	wire [(2*DATA_WIDTH)-1:0] extended_right;
	assign extended_right = {{DATA_WIDTH{right.data[DATA_WIDTH-1]}},right.data};
	wire [(2*DATA_WIDTH)-1:0] padded_left;
	assign padded_left = {{DATA_WIDTH{1'b0}},left.data};
	wire [(2*DATA_WIDTH)-1:0] padded_right;
	assign padded_right = {{DATA_WIDTH{1'b0}},right.data};
	always_comb begin
		case (opcode)
			ALU_OP_EQQ: begin
				next_result = {DATA_WIDTH{left.data == right.data}};
				next_overflow = 0;
				consume_left = 1;
				consume_right = 1;
				produce_result = 1;
				produce_overflow = 0;
			end
			ALU_OP_NEQ: begin
				next_result = {DATA_WIDTH{left.data != right.data}};
				next_overflow = 0;
				consume_left = 1;
				consume_right = 1;
				produce_result = 1;
				produce_overflow = 0;
			end
			ALU_OP_ADDN: begin
				{next_overflow, next_result} =
					$unsigned(padded_left) + $unsigned(padded_right);
				consume_left = 1;
				consume_right = 1;
				produce_result = 1;
				produce_overflow = 1;
			end
			ALU_OP_ADDZ: begin
				{next_overflow, next_result} =
					$signed(extended_left) + $signed(extended_right);
				consume_left = 1;
				consume_right = 1;
				produce_result = 1;
				produce_overflow = 1;
			end
			ALU_OP_SUBN: begin
				{next_overflow, next_result} =
					$unsigned(padded_left) - $unsigned(padded_right);
				consume_left = 1;
				consume_right = 1;
				produce_result = 1;
				produce_overflow = 1;
			end
			ALU_OP_SUBZ: begin
				{next_overflow, next_result} =
					$signed(extended_left) - $signed(extended_right);
				consume_left = 1;
				consume_right = 1;
				produce_result = 1;
				produce_overflow = 1;
			end
			ALU_OP_LESN: begin
				next_result =
					{DATA_WIDTH{$unsigned(left.data) < $unsigned(right.data)}};
				next_overflow = 0;
				consume_left = 1;
				consume_right = 1;
				produce_result = 1;
				produce_overflow = 0;
			end
			ALU_OP_LESZ: begin
				next_result =
					{DATA_WIDTH{$signed(left.data) < $signed(right.data)}};
				next_overflow = 0;
				consume_left = 1;
				consume_right = 1;
				produce_result = 1;
				produce_overflow = 0;
			end
			ALU_OP_LEQN: begin
				next_result =
					{DATA_WIDTH{$unsigned(left.data) <= $unsigned(right.data)}};
				next_overflow = 0;
				consume_left = 1;
				consume_right = 1;
				produce_result = 1;
				produce_overflow = 0;
			end
			ALU_OP_LEQZ: begin
				next_result =
					{DATA_WIDTH{$signed(left.data) <= $signed(right.data)}};
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

