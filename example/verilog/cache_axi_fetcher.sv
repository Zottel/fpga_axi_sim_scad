`default_nettype none

module cache_axi_fetcher
#(ADDR_WIDTH=32,
  DATA_WIDTH=32)
( input wire clock,
  input wire [ADDR_WIDTH-1:0] req_addr,
  input wire req_valid,
  output wire req_ack,
  output wire [DATA_WIDTH-1:0] resp_data,
  output wire resp_valid,
  input wire resp_ack,
  axi_interface.master axi);
	
	// Default settings from Xilinx Vitis RTL kernel example.
	// https://github.com/Xilinx/SDAccel_Examples/
	assign axi.AWID     = 1'b0;    // Write transaction ID 0.
	assign axi.AWBURST  = 2'b01;   // Burst type INCR.
	assign axi.AWLOCK   = 2'b00;   // No locking.
	assign axi.AWCACHE  = 4'b0011; // Normal Non-cacheable Bufferable.
	assign axi.AWPROT   = 3'b000;  // No protection.
	assign axi.AWQOS    = 4'b0000; // QOS not relevant.
	assign axi.AWREGION = 4'b0000; // Region 0.
	assign axi.ARBURST  = 2'b01;   // Burst type INCR.
	assign axi.ARLOCK   = 2'b00;   // No locking.
	assign axi.ARCACHE  = 4'b0011; // Normal Non-cacheable Bufferable.
	assign axi.ARPROT   = 3'b000;  // No protection.
	assign axi.ARQOS    = 4'b0000; // QOS not relevant.
	assign axi.ARREGION = 4'b0000; // Region 0.
	
	// Disable outgoing writes and do not accept their responses.
	assign axi.AWVALID = 1'b0;
	assign axi.AWADDR  = 0;
	assign axi.AWSIZE  = 0;
	assign axi.AWLEN   = 0;
	assign axi.WVALID  = 1'b0;
	assign axi.WSTRB   = 1;
	assign axi.WLAST   = 1;
	assign axi.WDATA   = 1;
	assign axi.BREADY  = 1'b0;
	
	assign axi.ARID    = 1'b0;    // Read transaction ID 0.
	
	assign axi.ARVALID = req_valid;
	assign req_ack = axi.ARREADY;
	/* verilator lint_off WIDTH */
	assign axi.ARADDR = req_addr;
	assign axi.ARSIZE = $clog2(DATA_WIDTH / 8);
	/* verilator lint_on WIDTH */
	assign axi.ARLEN = 0; // one beat
	
	assign resp_valid = axi.RVALID;
	assign axi.RREADY = resp_ack;
	// axi.RLAST
	assign resp_data = axi.RDATA;
	// axi.RID
	// TODO: Check axi.RRESP?
	
	`ifdef FORMAL
		
	`endif
endmodule
