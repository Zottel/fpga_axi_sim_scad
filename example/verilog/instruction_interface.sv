`default_nettype none

interface instruction_interface
	#(parameter ADDR_WIDTH=8, DATA_WIDTH=32);
	logic [ADDR_WIDTH-1:0] move_from;
	logic [ADDR_WIDTH-1:0] move_to;
	logic move_valid;
	logic move_ack;

	logic [ADDR_WIDTH-1:0] immediate_addr;
	logic [DATA_WIDTH-1:0] immediate;
	logic immediate_valid;
	logic immediate_ack;
	
	modport producer(
		output move_from, move_to, move_valid,
		input move_ack,
		
		output immediate_addr, immediate, immediate_valid,
		input immediate_ack
	);
	
	modport consumer(
		input move_from, move_to, move_valid,
		output move_ack,
		
		input immediate_addr, immediate, immediate_valid,
		output immediate_ack
	);
endinterface
