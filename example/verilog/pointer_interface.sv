`default_nettype none

interface pointer_interface
	#(parameter PTR_WIDTH=32);
	logic [PTR_WIDTH-1:0] ptr;
	logic valid;
	logic ack;
	
	modport producer(
		output ptr, valid,
		input ack
	);
	
	modport consumer(
		input ptr, valid,
		output ack
	);
endinterface

