`default_nettype none

module fifo_pointers
	#(parameter WIDTH=32, DEPTH=64) (
	input  wire             clock,
	input  wire [WIDTH-1:0] in,
	input  wire             in_valid,
	output wire             in_ack,
	output wire [WIDTH-1:0] out,
	output wire             out_valid,
	input  wire             out_ack
);
	reg [WIDTH-1:0]         content [DEPTH-1:0];
	
	reg [$clog2(DEPTH)-1:0] tail = 0; // Write pointer.
	reg [$clog2(DEPTH)-1:0] head = 0; // Read pointer.
	reg                     full = 0;
	
	wire empty;
	assign empty = !full && (tail == head);
	
	wire consume_input;
	assign consume_input = !full && in_valid;
	
	wire consume_output;
	assign consume_output = !empty && out_ack;
	
	wire [$clog2(DEPTH)-1:0] next_tail;
	wire [$clog2(DEPTH)-1:0] next_head;
	
	assign next_tail = ({{(32-$clog2(DEPTH)){1'b0}},tail} == (DEPTH-1)) ? 0 : (tail + 1);
	assign next_head = ({{(32-$clog2(DEPTH)){1'b0}},head} == (DEPTH-1)) ? 0 : (head + 1);
	
	always @ (posedge clock) begin
		if (consume_output && consume_input) begin
			content[tail] <= in;
			
			head <= next_head;
			tail <= next_tail;
			
		end else if (consume_output) begin
			
			head <= next_head;
			
			full <= 0;
			
		end else if (consume_input) begin
			content[tail] <= in;
			
			tail <= next_tail;
			
			if (next_tail == head)
				full <= 1;
		end
	end
	
	assign out = content[head];
	assign out_valid = !empty;
	assign in_ack = !full;
	
	`ifdef FORMAL
		assert property (tail <= (DEPTH-1));
		assert property (head <= (DEPTH-1));
		
		reg first_cycle = 1;
		always @ (posedge clock) begin
			first_cycle <= 0;
		end
		
		// General correctness criteria.
		always @ (posedge clock) begin
			// Once set, valid input remains stable until read.
			stable_input_valid: assume (first_cycle || !$past(in_valid && !in_ack)
			                            || in_valid);
			// Once set, valid input remains stable until read.
			stable_output_ack: assume (first_cycle || !$past(out_ack && !out_valid)
			                           || out_ack);
			
			stable_output_until_read:
				assert (first_cycle || !$past(!out_ack && out_valid)
				        || ($past(out) == out));
		end
		
		// Fill counter and corresponding safety checks.
		reg [$clog2(DEPTH)+1:0] count = 0;
		always @ (posedge clock) begin
			count_is_difference_between_pointers:
				assert property (((head + count) % DEPTH) == tail);
			
			if (in_valid && in_ack && out_valid && out_ack) begin
				at_least_one_to_read_when_read_and_write:
					assert property (count > 0);
				count <= count;
			end else if (in_valid && in_ack) begin
				count_read_beyond_depth: assert property (count < DEPTH);
				count <= count + 1;
			end else if (out_valid && out_ack) begin
				count_read_after_empty: assert property (count > 0);
				count <= count - 1;
			end
			// Check number of stored elements against bounds.
			count_bounds: assert (count <= DEPTH);
			count_equals_empty: assert ((count == 0) == (empty == 1));
			count_equals_full: assert ((count == DEPTH) == (full == 1));
		end
		
		// Reachability of corner cases:
		reg was_full = 0;
		always @ (posedge clock) begin
			cover_count_empty: cover (count == 0);
			cover_count_full: cover (count == DEPTH);
			
			was_full <= was_full || (count == DEPTH);
			cover_count_full_then_empty: cover (was_full && (count == 0));
		end
		
		
		// Content-correctness proof:
		// IDEA: For any sampled input, it will be seen at the output
		//       after count many output values have been read.
		//
		// Implementation:
		// When an input is sampled (proof sets sample to 1),
		// the current count of stored elements is remembered in
		// sampled_countdown. That countdown is then decremented for each
		// read output value.
		(* anyseq *) wire sample; // anyseq => Solvers may assign value any cycle.
		reg [WIDTH-1:0] sampled_input = 0; // Sampled value.
		reg [WIDTH-1:0] sampled_countdown = 0; // Sampled fill counter.
		// Only sample when no previous sample is active.
		assume property (!sample || (sampled_countdown == 0));
		assume property ((sampled_countdown == 0) || (sampled_countdown < count));
		// Only sample when input is actually read.
		assume property (!sample || (in_valid && in_ack));
		always @ (posedge clock) begin
			if (sample) begin
				sampled_input <= in;
				if (out_valid && out_ack) begin
					sampled_countdown <= count - 1;
				end else begin
					sampled_countdown <= count;
				end
			end else begin
				if ((sampled_countdown > 0) && out_valid && out_ack) begin
					sampled_countdown <= sampled_countdown - 1;
				end
			end
			restrict_sampled_countdown: assert (sampled_countdown <= count);
			
			// There are essentially two ways to run an induction over data
			// from inputs to outputs: Including restrictions about internal state
			// or having liveness assertions that guarantee that the value we watch
			// has been input during out induction step.
			// Using liveness properties instead of internal state allows us to
			// verify without using internal state in out assertions, but is A LOT
			// more expensive. (From a couple of seconds with internal state
			// assertion to many hours without.)
			
			// If you want induction without internal state, liveness criteria and
			// huge induction step numbers are an alternative.
			//require_some_output_reads:
			//	assume (out_ack||$past(out_ack,1)||$past(out_ack,2)||$past(out_ack,3)
			//	      ||$past(out_ack,4)||$past(out_ack,5)||$past(out_ack,6)
			//	      ||$past(out_ack,8)||$past(out_ack,9));
			
			// Induction helper that asserts internal state.
			correct_value_in_memory:
				assert ((sampled_countdown == 0)
				        || (content[(head+sampled_countdown)%DEPTH] == sampled_input));
			
			// Actual correctness criteria: The sampled value will arrive at output
			// after the `count` values in front of it have been read.
			output_sampled_value_correctly:
				assert(first_cycle
				       || !$past(((sampled_countdown == 1) && out_ack)
				                 || (sample && (count == 0)))
				       || (out_valid && (out == sampled_input)));
		end

	`endif
	
endmodule

