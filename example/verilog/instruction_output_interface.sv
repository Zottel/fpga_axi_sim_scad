`default_nettype none

interface instruction_output_interface
	#(parameter ADDR_WIDTH=8, DATA_WIDTH=32);
	logic [ADDR_WIDTH-1:0] move_to;
	logic move_valid;
	logic move_ack;
	
	modport producer(
		output move_to, move_valid,
		input move_ack
	);
	
	modport consumer(
		input move_to, move_valid,
		output move_ack
	);
endinterface
