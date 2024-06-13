`default_nettype none

interface mem_interface
	#(parameter MEMADDR_WIDTH=32, DATA_WIDTH=32);
	logic [MEMADDR_WIDTH-1:0] read_address;
	logic read_address_valid;
	logic [DATA_WIDTH-1:0] read_data;
	logic read_data_valid;
	
	logic [MEMADDR_WIDTH-1:0] write_address;
	logic [DATA_WIDTH-1:0] write_data;
	logic write_valid;
	logic write_ack;
	
	modport requester(
		output read_address, read_address_valid,
		input read_data, read_data_valid,
		
		output write_address, write_data, write_valid,
		input write_ack
	);
	
	modport responder(
		input read_address, read_address_valid,
		output read_data, read_data_valid,
		
		input write_address, write_data, write_valid,
		output write_ack
	);
endinterface
