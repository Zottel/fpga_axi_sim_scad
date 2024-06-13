// Compared to a normal skid buffer, this does not implement the regular
// pipeline interface of our system.  Values are output for a delayed RAM
// to consume.  For maximum performance, a "data has been processed" ACK from
// the memory will allow new input data to be forwarded within the ACK'ed cycle.

`default_nettype none

module skid_like_mem_buffer
	#(parameter DATA_WIDTH=32) (
		input wire clock,
	  data_interface.consumer in,
	  data_interface.producer out);
	
	reg reg_valid = 0;
	reg [DATA_WIDTH-1:0] reg_value = 0;
	
	wire input_available = in.valid;
	
	// Acknowledge incoming data when buffer register empty or will be empty
	// otherwise.
	assign in.ack = !reg_valid || (reg_valid && out.ack);
	
	wire current_valid = (reg_valid && !out.ack) || in.valid;
	
	wire [DATA_WIDTH-1:0] current_value =
		(reg_valid && !out.ack) ? reg_value : (in.valid ? in.data : 0);
	
	assign out.valid = current_valid;
	assign out.data = current_value;
	
	always @ (posedge clock) begin
		if ((!reg_valid && in.valid) || out.ack) begin
			reg_valid <= in.valid;
			reg_value <= in.data;
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
			input_data_stable_until_consumed:
				assume (!$past(in.valid && !in.ack) || ($past(in.data) == in.data));
			
			ouput_data_stable_until_consumed:
				assert ((cycle == 0) // $past(<expr>) undefined in first cycle.
				        || !($past(out.valid) && !out.ack)
				        || ($past(out.data) == out.data));
			
			do_not_read_input_while_full:
				assert (!reg_valid || out.ack || !in.ack);
			
			just_run:
				cover (cycle > 10);
			
			just_some_values:
				cover (cycle > 10 && reg_valid && reg_value);
			
			throughput_1:
				cover ((cycle > 5)
				       && ($past(reg_value, 1) != reg_value)
				       && ($past(reg_value, 2) != reg_value)
				       && ($past(reg_value, 1) != $past(reg_value, 2)));

			throughput_2:
				cover ((cycle > 5)
				       && ($past(reg_valid, 1))
				       && ($past(reg_valid, 2))
				       && ($past(reg_valid, 3))
				       && ($past(reg_value, 1) != reg_value)
				       && ($past(reg_value, 2) != reg_value)
				       && ($past(reg_value, 3) != reg_value)
				       && ($past(reg_value, 1) != $past(reg_value, 2))
				       && ($past(reg_value, 2) != $past(reg_value, 3))
				       && ($past(reg_value, 1) != $past(reg_value, 3)));
		end
	`endif
endmodule



