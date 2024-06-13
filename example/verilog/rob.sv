`default_nettype none

module rob
	#(parameter DATA_WIDTH=32, DEPTH=5) (
	input wire clock,
	data_interface.consumer in,
	data_interface.producer out);
	
	fifo_pointers
		#(.WIDTH(DATA_WIDTH), .DEPTH(DEPTH))
		data_fifo (
			.clock(clock),
			.in(in.data),
			.in_valid(in.valid),
			.in_ack(in.ack),
			.out(out.data),
			.out_valid(out.valid),
			.out_ack(out.ack));
endmodule

