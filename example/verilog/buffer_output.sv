`default_nettype none

module buffer_output #(ADDR_WIDTH=8, DATA_WIDTH=32, FROM_ADDR=0, DEPTH=5) (
	input wire clock,
	message_interface.producer dtn,
	instruction_output_interface.consumer cu,
	data_interface.consumer data);
	
	assign dtn.from = FROM_ADDR;
	wire data_valid;
	wire addr_valid;
	//assign dtn.valid = data_valid && addr_valid;
	assign dtn.valid = data_valid && addr_valid && (dtn.to != {ADDR_WIDTH{1'b1}});
	
	wire shared_ack;
	//assign shared_ack = data_valid && addr_valid && dtn.ack;
	assign shared_ack = data_valid && addr_valid && (dtn.ack || (dtn.to == {ADDR_WIDTH{1'b1}}));
	
	
	fifo_pointers
		#(.WIDTH(DATA_WIDTH), .DEPTH(DEPTH))
		data_fifo (
			.clock(clock),
			.in(data.data),
			.in_valid(data.valid),
			.in_ack(data.ack),
			.out(dtn.data),
			.out_valid(data_valid),
			.out_ack(shared_ack));
	
	fifo_pointers
		#(.WIDTH(ADDR_WIDTH), .DEPTH(DEPTH))
		addr_fifo (
			.clock(clock),
			.in(cu.move_to),
			.in_valid(cu.move_valid),
			.in_ack(cu.move_ack),
			.out(dtn.to),
			.out_valid(addr_valid),
			.out_ack(shared_ack));
	
	`ifdef FORMAL
		always @ (posedge clock) begin
			only_together_valid:
				assert (!dtn.valid || (data_valid && addr_valid));
			ack_only_when_both_valid:
				assert (!shared_ack || (data_valid && addr_valid));
		end
	`endif
endmodule
