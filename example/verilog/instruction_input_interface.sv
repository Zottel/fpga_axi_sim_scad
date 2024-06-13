`default_nettype none

interface instruction_input_interface
	#(parameter ADDR_WIDTH=8, DATA_WIDTH=32);
	logic [ADDR_WIDTH-1:0] move_from;
	logic move_valid;
	logic move_ack;

	logic [DATA_WIDTH-1:0] immediate;
	logic immediate_valid;
	logic immediate_ack;
	
	modport producer(
		output move_from, move_valid,
		input move_ack,
		
		output immediate, immediate_valid,
		input immediate_ack
	);
	
	modport consumer(
		input move_from, move_valid,
		output move_ack,
		
		input immediate, immediate_valid,
		output immediate_ack
	);
endinterface
