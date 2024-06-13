`default_nettype none

interface data_interface
	#(parameter DATA_WIDTH=32);
	logic [DATA_WIDTH-1:0] data;
	logic valid;
	logic ack;
	
	modport producer(
		output data, valid,
		input ack
	);
	
	modport consumer(
		input data, valid,
		output ack
	);
endinterface
