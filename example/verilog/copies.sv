`default_nettype none

module copies
	#(parameter DATA_WIDTH=32, COUNT_WIDTH=16) (
		input wire clock,
		input wire [COUNT_WIDTH-1:0] in_count,
	  data_interface.consumer in,
	  data_interface.producer out);
	
	reg [COUNT_WIDTH-1:0] count = 0;
	reg [DATA_WIDTH-1:0] value = 0;
	
	wire input_available;
	assign input_available = in.valid && (in_count > 0);
	
	// Acknowledge incoming data when we have space or it needs zero copies.
	assign in.ack = (count == 0) || ((count == 1) && out.ack);
	
	wire [COUNT_WIDTH-1:0] current_count;
	assign current_count = (count > 0) ? count : (in.valid ? in_count : 0);
	
	wire [DATA_WIDTH-1:0] current_value;
	assign current_value = (count > 0) ? value : (in.valid ? in.data : 0);
	
	wire valid_output;
	assign valid_output = current_count > 0;
	
	assign out.valid = valid_output;
	assign out.data = current_value;
	
	wire consume_output;
	assign consume_output = valid_output && out.ack;
	
	wire consume_input;
	assign consume_input = input_available &&
	                       ((count == 0) || ((count == 1) && consume_output));
	
	wire [COUNT_WIDTH-1:0] next_count;
	assign next_count = (((count == 1) && !consume_output) || (count > 1))
	                    ? (count - (consume_output?1:0))
	                    : (input_available
	                       ? (in_count - ((consume_output && (count == 0))?1:0))
	                       : 0);
	
	always @ (posedge clock) begin
		count <= next_count;
		
		if (consume_input && (next_count > 0)) begin
			value <= in.data;
		end
	end
	
	`ifdef FORMAL
		reg [31:0] cycle = 0;
		
		always @ (posedge clock) begin
			cycle <= cycle + 1;
			
			output_ack_stable_until_consumed:
				assume (!$past(out.ack && !out.valid) || out.ack);
			
			input_valid_stable_until_consumed:
				assume (!$past(in.valid && !in.ack) || in.valid);
			input_count_stable_until_consumed:
				assume (!$past(in.valid && !in.ack) || ($past(in_count) == in_count));
			input_data_stable_until_consumed:
				assume (!$past(in.valid && !in.ack) || ($past(in.data) == in.data));
			
			ouput_data_stable_until_consumed:
				assert ((cycle == 0) // $past(<expr>) undefined in first cycle.
				        || !$past(out.valid && !out.ack)
				        || ($past(out.data) == out.data));
			
			do_not_read_while_full:
				assert (!((count > 0) && ((count - (out.valid && out.ack)) > 0))
				        || !in.ack);
			
			// Optional: More interesting traces.
			//assume (in.data != 0); assert (!out.valid || (out.data != 0));
			
			at_least_some_output_after_nonzero_input:
				assert ((cycle == 0) // $past(<expr>) undefined in first cycle.
				        || !$past((in_count > 0 && in.ack && in.valid))
				        || ($past(in.data == out.data)
				            || ($past(in.data) == out.data)));
			
			// Starting off empty, new value arrives and may be output in
			// the same cycle.
			correct_output_start0:
				assert ((cycle == 0)
				        || !$past((count == 0) && (in_count > 0) && in.ack && in.valid)
				        || ($past(in.data == out.data)
				            && (count == $past(in_count - (out.valid && out.ack)))));
			
			// Last value has count 1 and is read, can still read input.
			correct_output_start1:
				assert ((cycle == 0)
				        || !$past((count == 1) && (in_count > 0) && in.ack && in.valid)
				        || (($past(in.data) == out.data)
				            && (count == $past(in_count))));
			
			
			// Output remains stable and count is decremented by reads.
			correct_output_ongoing:
				assert ((cycle == 0)
				        || !$past((count > 0) && ((count - (out.valid && out.ack)) > 0))
				        || (($past(out.data) == out.data)
				            && (count == $past(count - (out.valid && out.ack)))));
			
			minimal_run:
				cover (count > 3);
			more_copies:
				cover ((cycle > 48) && ($past(count, 32) == 16) && (count == 0));
		end
	`endif
endmodule

