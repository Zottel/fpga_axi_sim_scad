`default_nettype none

interface axi_lite_interface
#(parameter ADDR_WIDTH=6,
            DATA_WIDTH=32);

	// Global
	logic ACLK;
	logic ARSTN; // Reset, active low.
	// Address Write
	logic                  AWVALID;
	logic                  AWREADY;
	logic [ADDR_WIDTH-1:0] AWADDR;

	// Write Data
	logic                    WVALID;
	logic                    WREADY;
	logic [DATA_WIDTH-1:0]   WDATA;
	logic [DATA_WIDTH/8-1:0] WSTRB; // which bytes of WDATA are valid
	
	// Address Read
	logic                  ARVALID;
	logic                  ARREADY;
	logic [ADDR_WIDTH-1:0] ARADDR;
	
	// Read Data
	logic                  RVALID;
	logic                  RREADY;
	logic [DATA_WIDTH-1:0] RDATA;
	logic [1:0]            RRESP; // locking or error results
	
	// Write Response
	logic                BVALID;
	logic                BREADY;
	logic [1:0]          BRESP; // locking or error results.
	
	modport master (
		input ACLK, input ARSTN,
		output AWVALID, input AWREADY, output AWADDR,
		output WVALID, input WREADY, output WDATA, output WSTRB,
		output ARVALID, input ARREADY, output ARADDR,
		input RVALID, output RREADY, input RDATA, input RRESP,
		input BVALID, output BREADY, input BRESP
	);
	
	modport slave (
		input ACLK, input ARSTN,
		input AWVALID, output AWREADY, input AWADDR,
		input WVALID, output WREADY, input WDATA, input WSTRB,
		input ARVALID, output ARREADY, input ARADDR,
		output RVALID, input RREADY, output RDATA, output RRESP,
		output BVALID, input BREADY, output BRESP
	);
	
endinterface

