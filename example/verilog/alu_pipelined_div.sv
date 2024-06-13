`default_nettype none

module alu_pipelined_div
	#(parameter DATA_WIDTH=32,
		OPCODE_WIDTH = 6,
		ALU_OP_DIVN = 6'd17,
		ALU_OP_DIVZ = 6'd18) (
		input wire clock,
		data_interface.consumer operator,
		data_interface.consumer left,
		data_interface.consumer right,
		data_interface.producer result,
		data_interface.producer overflow);
	
	localparam STATE_IDLE = 0;
	localparam STATE_RUNNING = 1;
	localparam STATE_READY = 2;
	
	wire inputs_ready = operator.valid && left.valid && right.valid;
	wire inputs_ack = inputs_ready && (state == STATE_IDLE);
	
	assign operator.ack = inputs_ack;
	assign left.ack = inputs_ack;
	assign right.ack = inputs_ack;
	
	reg [1:0] state = STATE_IDLE;
	
	// sum = dividend / divisor
	reg [(2*DATA_WIDTH)-1:0] dividend = 0;
	reg [(2*DATA_WIDTH)-1:0] divisor = 0;
	
	// Intermediate: dividend - divisor.
	wire [(2*DATA_WIDTH)-1:0] diff = dividend - divisor;
	wire diff_is_negative = $signed(diff) < 0;
	
	// Remainder will be in dividend register in the end.
	assign overflow.data = dividend[DATA_WIDTH-1:0];
	
	reg [DATA_WIDTH-1:0] sum = 0;
	assign result.data = sum[DATA_WIDTH-1:0];
	
	// Workaround to verilog having problems with constants.
	wire [31:0] start_remaining_bits = DATA_WIDTH-1;
	
	reg [$clog2(DATA_WIDTH)-1:0] remaining_bits = 0;
	
	reg result_available = 0;
	reg overflow_available = 0;
	assign result.valid = result_available;
	assign overflow.valid = overflow_available;
	
	always @ (posedge clock) begin
		if (state == STATE_IDLE) begin
			if (inputs_ready) begin
				state <= STATE_RUNNING;
				dividend <= {{DATA_WIDTH{1'b0}},left.data[DATA_WIDTH-1:0]};
				divisor <= {1'b0,right.data[DATA_WIDTH-1:0],{(DATA_WIDTH-1){1'b0}}};
				remaining_bits <= start_remaining_bits[$clog2(DATA_WIDTH)-1:0];
			end
		end else if (state == STATE_RUNNING) begin
			// Shift divisor by one bit.
			divisor <= {1'b0, divisor[(2*DATA_WIDTH)-1:1]};
			
			if (diff_is_negative) begin
				sum <= {sum[DATA_WIDTH-2:0], 1'b0};
				dividend <= dividend;
			end else begin
				sum <= {sum[DATA_WIDTH-2:0], 1'b1};
				dividend <= diff;
			end
			
			// Check if we are done.
			remaining_bits <= remaining_bits-1;
			if (remaining_bits == 0) begin
				state <= STATE_READY;
				result_available <= 1;
				overflow_available <= 1;
			end
		end else if (state == STATE_READY) begin
			result_available <= result_available && !result.ack;
			overflow_available <= overflow_available && !overflow.ack;
			if ((!result_available || result.ack) &&
			    (!overflow_available || overflow.ack)) begin
				state <= STATE_IDLE;
			end
		end else begin
			// TODO: Remove or indicate error!
			state <= state;
		end
	end

	`ifdef FORMAL
	reg [(2*DATA_WIDTH)-1:0] cycle = 0;
	reg [DATA_WIDTH-1:0] last_left = 0;
	reg [DATA_WIDTH-1:0] last_right = 0;
	
	always @ (posedge clock) begin
		cycle <= cycle + 1;
		
		if (inputs_ack) begin
			last_left <= left.data;
			last_right <= right.data;
		end
		
		reach_state_is_ready:
			cover(state == STATE_READY);
		reach_random_sum:
			cover(sum == 3);
		reach_example_output:
			cover(result.valid == 1 && result.data == 7 &&
			      overflow.valid == 1 && overflow.data == 9);
		reach_from_ready_to_idle:
			cover($past(state == STATE_READY) && (state == STATE_IDLE));
		
		correct_result:
			assert((state != STATE_READY) ||
			       (last_left == (result.data * last_right) + overflow.data));
	end
	`endif
endmodule

