`default_nettype none

module axi_address_offset
#(ID_WIDTH=1, ADDR_WIDTH=64, DATA_WIDTH=64) (
		input wire [ADDR_WIDTH-1:0] offset,
		axi_interface.master to_slave,
		axi_interface.slave to_master
	);

// Address write
assign to_slave.AWVALID  = to_master.AWVALID;
assign to_master.AWREADY = to_slave.AWREADY;
assign to_slave.AWADDR   = to_master.AWADDR + offset;
assign to_slave.AWID     = to_master.AWID;
assign to_slave.AWLEN    = to_master.AWLEN;
assign to_slave.AWSIZE   = to_master.AWSIZE;
assign to_slave.AWBURST  = to_master.AWBURST;
assign to_slave.AWLOCK   = to_master.AWLOCK;
assign to_slave.AWCACHE  = to_master.AWCACHE;
assign to_slave.AWPROT   = to_master.AWPROT;
assign to_slave.AWQOS    = to_master.AWQOS;
assign to_slave.AWREGION = to_master.AWREGION;

// Write data
assign to_slave.WVALID  = to_master.WVALID;
assign to_master.WREADY = to_slave.WREADY;
assign to_slave.WDATA   = to_master.WDATA;
assign to_slave.WSTRB   = to_master.WSTRB;
assign to_slave.WLAST   = to_master.WLAST;

// Address read
assign to_slave.ARVALID  = to_master.ARVALID;
assign to_master.ARREADY = to_slave.ARREADY;
assign to_slave.ARADDR   = to_master.ARADDR + offset;
assign to_slave.ARID     = to_master.ARID;
assign to_slave.ARLEN    = to_master.ARLEN;
assign to_slave.ARSIZE   = to_master.ARSIZE;
assign to_slave.ARBURST  = to_master.ARBURST;
assign to_slave.ARLOCK   = to_master.ARLOCK;
assign to_slave.ARCACHE  = to_master.ARCACHE;
assign to_slave.ARPROT   = to_master.ARPROT;
assign to_slave.ARQOS    = to_master.ARQOS;
assign to_slave.ARREGION = to_master.ARREGION;

// Read data
assign to_master.RVALID = to_slave.RVALID;
assign to_slave.RREADY  = to_master.RREADY;
assign to_master.RDATA  = to_slave.RDATA;
assign to_master.RLAST  = to_slave.RLAST;
assign to_master.RID    = to_slave.RID;
assign to_master.RRESP  = to_slave.RRESP;

// Write response
assign to_master.BVALID = to_slave.BVALID;
assign to_slave.BREADY  = to_master.BREADY;
assign to_master.BID    = to_slave.BID;
assign to_master.BRESP  = to_slave.BRESP;

endmodule
