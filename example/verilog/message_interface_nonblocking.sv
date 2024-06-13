`default_nettype none

interface message_interface_nonblocking
	#(parameter ADDR_WIDTH=8, DATA_WIDTH=32);
	logic [ADDR_WIDTH-1:0] from;
	logic [ADDR_WIDTH-1:0] to;
	logic [DATA_WIDTH-1:0] data;
	logic valid;
	
	modport producer(
		output from, to, data, valid
	);
	
	modport consumer(
		input from, to, data, valid
	);
endinterface
