`default_nettype none

module axi_lite_buffer 
#(parameter
	ADDR_WIDTH=6,
	DATA_WIDTH=32,
	BUFFER_DEPTH=4
) (
	input wire ap_clk,
	axi_lite_interface.slave to_master,
	axi_lite_interface.master to_slave
);
/* verilator lint_off PINCONNECTEMPTY */
fifo_pointers #(.WIDTH(ADDR_WIDTH), .DEPTH(BUFFER_DEPTH))
	awaddr_buff (
		.clock(ap_clk),
		.in      (to_master.AWADDR),
		.in_valid(to_master.AWVALID),
		.in_ack  (to_master.AWREADY),
		.out      (to_slave.AWADDR),
		.out_valid(to_slave.AWVALID),
		.out_ack  (to_slave.AWREADY)
	);

fifo_pointers #(.WIDTH(DATA_WIDTH), .DEPTH(BUFFER_DEPTH))
	wdata_buff (
		.clock(ap_clk),
		.in      (to_master.WDATA),
		.in_valid(to_master.WVALID),
		.in_ack  (to_master.WREADY),
		.out      (to_slave.WDATA),
		.out_valid(to_slave.WVALID),
		.out_ack  (to_slave.WREADY)
	);

fifo_pointers #(.WIDTH(DATA_WIDTH/8), .DEPTH(BUFFER_DEPTH))
	wstrb_buff (
		.clock(ap_clk),
		.in      (to_master.WSTRB),
		.in_valid(to_master.WVALID),
		.in_ack  (),
		.out      (to_slave.WSTRB),
		.out_valid(),
		.out_ack  (to_slave.WREADY) // Already handled by wdata_buff
	);

fifo_pointers #(.WIDTH(ADDR_WIDTH), .DEPTH(BUFFER_DEPTH))
	araddr_buff (
		.clock(ap_clk),
		.in      (to_master.ARADDR),
		.in_valid(to_master.ARVALID),
		.in_ack  (to_master.ARREADY),
		.out      (to_slave.ARADDR),
		.out_valid(to_slave.ARVALID),
		.out_ack  (to_slave.ARREADY)
	);

fifo_pointers #(.WIDTH(DATA_WIDTH), .DEPTH(BUFFER_DEPTH))
	rdata_buff (
		.clock(ap_clk),
		.in      (to_slave.RDATA),
		.in_valid(to_slave.RVALID),
		.in_ack  (to_slave.RREADY),
		.out      (to_master.RDATA),
		.out_valid(to_master.RVALID),
		.out_ack  (to_master.RREADY)
	);
wire rresp_ignore_ack;
wire rresp_ignore_valid;
fifo_pointers #(.WIDTH(2), .DEPTH(BUFFER_DEPTH))
	rresp_buff (
		.clock(ap_clk),
		.in      (to_slave.RRESP),
		.in_valid(to_slave.RVALID),
		.in_ack  (rresp_ignore_ack),
		.out      (to_master.RRESP),
		.out_valid(rresp_ignore_valid),
		.out_ack  (to_master.RREADY) // Already handled by rdata_buff.
	);

fifo_pointers #(.WIDTH(2), .DEPTH(BUFFER_DEPTH))
	bresp_buff (
		.clock(ap_clk),
		.in      (to_slave.BRESP),
		.in_valid(to_slave.BVALID),
		.in_ack  (to_slave.BREADY),
		.out      (to_master.BRESP),
		.out_valid(to_master.BVALID),
		.out_ack  (to_master.BREADY)
	);

/* verilator lint_on PINCONNECTEMPTY */
endmodule
