`default_nettype none

interface buffer_line_interface
	#(parameter ADDR_WIDTH=8, DATA_WIDTH=32);
	logic [ADDR_WIDTH-1:0] addr;
	logic [DATA_WIDTH-1:0] data;
	logic addr_valid;
	logic data_valid;
	logic data_just_matched;
	logic ack;
	
	modport producer(
		output addr, addr_valid,
		output data, data_valid, data_just_matched,
		input ack
	);
	
	modport consumer(
		input addr, addr_valid,
		input data, data_valid, data_just_matched,
		output ack
	);
endinterface
