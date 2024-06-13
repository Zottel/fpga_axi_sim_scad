// AXi Buffer

// Decouple AXI channels by inserting FIFOs.  For efficiency, only signals
// which are not constant are run through the FIFOs. Others are just
// forwarded.

`default_nettype none

module axi_buffer
#(parameter
	ID_WIDTH=1,
	ADDR_WIDTH=64,
	DATA_WIDTH=64,
	BUFFER_DEPTH=4
) (
	input wire ap_clk,
	axi_interface.slave to_master,
	axi_interface.master to_slave
);
/* verilator lint_off PINCONNECTEMPTY */
// Address write
//assign to_slave.AWVALID  = to_master.AWVALID;
//assign to_master.AWREADY = to_slave.AWREADY;
//assign to_slave.AWADDR   = to_master.AWADDR;
//assign to_slave.AWID     = to_master.AWID;
//assign to_slave.AWLEN    = to_master.AWLEN;
//assign to_slave.AWSIZE   = to_master.AWSIZE;
assign to_slave.AWBURST  = to_master.AWBURST;
assign to_slave.AWLOCK   = to_master.AWLOCK;
assign to_slave.AWCACHE  = to_master.AWCACHE;
assign to_slave.AWPROT   = to_master.AWPROT;
assign to_slave.AWQOS    = to_master.AWQOS;
assign to_slave.AWREGION = to_master.AWREGION;
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
fifo_pointers #(.WIDTH(ID_WIDTH), .DEPTH(BUFFER_DEPTH))
	awid_buff (
		.clock(ap_clk),
		.in      (to_master.AWID),
		.in_valid(to_master.AWVALID),
		.in_ack  (),
		.out      (to_slave.AWID),
		.out_valid(),
		.out_ack  (to_slave.AWREADY)
	);
fifo_pointers #(.WIDTH(8), .DEPTH(BUFFER_DEPTH))
	awlen_buff (
		.clock(ap_clk),
		.in      (to_master.AWLEN),
		.in_valid(to_master.AWVALID),
		.in_ack  (),
		.out      (to_slave.AWLEN),
		.out_valid(),
		.out_ack  (to_slave.AWREADY)
	);
fifo_pointers #(.WIDTH(3), .DEPTH(BUFFER_DEPTH))
	awsize_buff (
		.clock(ap_clk),
		.in      (to_master.AWSIZE),
		.in_valid(to_master.AWVALID),
		.in_ack  (),
		.out      (to_slave.AWSIZE),
		.out_valid(),
		.out_ack  (to_slave.AWREADY)
	);

// Write data
//assign to_slave.WVALID  = to_master.WVALID;
//assign to_master.WREADY = to_slave.WREADY;
//assign to_slave.WDATA   = to_master.WDATA;
//assign to_slave.WSTRB   = to_master.WSTRB;
//assign to_slave.WLAST   = to_master.WLAST;
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
fifo_pointers #(.WIDTH(1), .DEPTH(BUFFER_DEPTH))
	wlast_buff (
		.clock(ap_clk),
		.in      (to_master.WLAST),
		.in_valid(to_master.WVALID),
		.in_ack  (),
		.out      (to_slave.WLAST),
		.out_valid(),
		.out_ack  (to_slave.WREADY) // Already handled by wdata_buff
	);

// Address read
//assign to_slave.ARVALID  = to_master.ARVALID;
//assign to_master.ARREADY = to_slave.ARREADY;
//assign to_slave.ARADDR   = to_master.ARADDR;
//assign to_slave.ARID     = to_master.ARID;
//assign to_slave.ARLEN    = to_master.ARLEN;
//assign to_slave.ARSIZE   = to_master.ARSIZE;
assign to_slave.ARBURST  = to_master.ARBURST;
assign to_slave.ARLOCK   = to_master.ARLOCK;
assign to_slave.ARCACHE  = to_master.ARCACHE;
assign to_slave.ARPROT   = to_master.ARPROT;
assign to_slave.ARQOS    = to_master.ARQOS;
assign to_slave.ARREGION = to_master.ARREGION;
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
fifo_pointers #(.WIDTH(ID_WIDTH), .DEPTH(BUFFER_DEPTH))
	arid_buff (
		.clock(ap_clk),
		.in      (to_master.ARID),
		.in_valid(to_master.ARVALID),
		.in_ack  (),
		.out      (to_slave.ARID),
		.out_valid(),
		.out_ack  (to_slave.ARREADY)
	);
fifo_pointers #(.WIDTH(8), .DEPTH(BUFFER_DEPTH))
	arlen_buff (
		.clock(ap_clk),
		.in      (to_master.ARLEN),
		.in_valid(to_master.ARVALID),
		.in_ack  (),
		.out      (to_slave.ARLEN),
		.out_valid(),
		.out_ack  (to_slave.ARREADY)
	);
fifo_pointers #(.WIDTH(3), .DEPTH(BUFFER_DEPTH))
	arsize_buff (
		.clock(ap_clk),
		.in      (to_master.ARSIZE),
		.in_valid(to_master.ARVALID),
		.in_ack  (),
		.out      (to_slave.ARSIZE),
		.out_valid(),
		.out_ack  (to_slave.ARREADY)
	);

// Read data
// assign to_master.RVALID = to_slave.RVALID;
// assign to_slave.RREADY  = to_master.RREADY;
// assign to_master.RDATA  = to_slave.RDATA;
//assign to_master.RLAST  = to_slave.RLAST;
//assign to_master.RID    = to_slave.RID;
// assign to_master.RRESP  = to_slave.RRESP;
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
fifo_pointers #(.WIDTH(1), .DEPTH(BUFFER_DEPTH))
	rlast_buff (
		.clock(ap_clk),
		.in      (to_slave.RLAST),
		.in_valid(to_slave.RVALID),
		.in_ack  (),
		.out      (to_master.RLAST),
		.out_valid(),
		.out_ack  (to_master.RREADY) // Already handled by rdata_buff.
	);
fifo_pointers #(.WIDTH(ID_WIDTH), .DEPTH(BUFFER_DEPTH))
	rid_buff (
		.clock(ap_clk),
		.in      (to_slave.RID),
		.in_valid(to_slave.RVALID),
		.in_ack  (),
		.out      (to_master.RID),
		.out_valid(),
		.out_ack  (to_master.RREADY) // Already handled by rdata_buff.
	);
fifo_pointers #(.WIDTH(2), .DEPTH(BUFFER_DEPTH))
	rresp_buff (
		.clock(ap_clk),
		.in      (to_slave.RRESP),
		.in_valid(to_slave.RVALID),
		.in_ack  (),
		.out      (to_master.RRESP),
		.out_valid(),
		.out_ack  (to_master.RREADY) // Already handled by rdata_buff.
	);

// Write response
// assign to_master.BVALID = to_slave.BVALID;
// assign to_slave.BREADY  = to_master.BREADY;
//assign to_master.BID    = to_slave.BID;
//assign to_master.BRESP  = to_slave.BRESP;
fifo_pointers #(.WIDTH(ID_WIDTH), .DEPTH(BUFFER_DEPTH))
	bid_buff (
		.clock(ap_clk),
		.in      (to_slave.BID),
		.in_valid(to_slave.BVALID),
		.in_ack  (to_slave.BREADY),
		.out      (to_master.BID),
		.out_valid(to_master.BVALID),
		.out_ack  (to_master.BREADY)
	);
fifo_pointers #(.WIDTH(2), .DEPTH(BUFFER_DEPTH))
	bresp_buff (
		.clock(ap_clk),
		.in      (to_slave.BRESP),
		.in_valid(to_slave.BVALID),
		.in_ack  (),
		.out      (to_master.BRESP),
		.out_valid(),
		.out_ack  (to_master.BREADY)
	);

/* verilator lint_on PINCONNECTEMPTY */
endmodule
