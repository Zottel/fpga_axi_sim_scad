`default_nettype none

interface axi_interface
#(parameter ID_WIDTH=1,
            ADDR_WIDTH=64,
            DATA_WIDTH=256);

	// Global, not useful here at the moment.
	// logic ACLK;
	// logic ARSTN; // Reset, active low.
	
	// Address Write
	logic                  AWVALID;
	logic                  AWREADY;
	logic [ADDR_WIDTH-1:0] AWADDR;
	logic [ID_WIDTH-1:0]   AWID;
	logic [7:0]            AWLEN;    // burst length
	logic [2:0]            AWSIZE;   // burst size
	logic [1:0]            AWBURST;  // burst type
	logic [1:0]            AWLOCK;   // lock type
	logic [3:0]            AWCACHE;  // buffer rules for transaction
	logic [2:0]            AWPROT;   // protection, security attribute
	logic [3:0]            AWQOS;    // qos, impl. specific behaviour
	logic [3:0]            AWREGION; // 4-bit id of mapped memory area
	
	// Write Data
	logic                    WVALID;
	logic                    WREADY;
	logic [DATA_WIDTH-1:0]   WDATA;
	logic [DATA_WIDTH/8-1:0] WSTRB; // which bytes of WDATA are valid
	logic                    WLAST;
	
	// Address Read
	logic                  ARVALID;
	logic                  ARREADY;
	logic [ADDR_WIDTH-1:0] ARADDR;
	logic [ID_WIDTH-1:0]   ARID;
	logic [7:0]            ARLEN;    // burst length
	logic [2:0]            ARSIZE;   // burst size
	logic [1:0]            ARBURST;  // burst type
	logic [1:0]            ARLOCK;   // lock type
	logic [3:0]            ARCACHE;  // buffer rules for transaction
	logic [2:0]            ARPROT;   // protection, security attribute
	logic [3:0]            ARQOS;    // qos, impl. specific behaviour
	logic [3:0]            ARREGION; // 4-bit id of mapped memory area
	
	// Read Data
	logic                  RVALID;
	logic                  RREADY;
	logic [DATA_WIDTH-1:0] RDATA;
	logic                  RLAST;
	logic [ID_WIDTH-1:0]   RID;
	logic [1:0]            RRESP; // locking or error results
	
	// Write Response
	logic                BVALID;
	logic                BREADY;
	logic [ID_WIDTH-1:0] BID;
	logic [1:0]          BRESP; // locking or error results.
	
	modport master (
		//output ACLK, output ARSTN,
		
		output AWVALID, input AWREADY,
		output AWADDR, output AWID, output AWLEN, output AWSIZE, output AWBURST,
		output AWLOCK, output AWCACHE, output AWPROT, output AWQOS, output AWREGION,
		
		output WVALID, input WREADY, output WDATA, output WSTRB, output WLAST,
		
		output ARVALID, input ARREADY, output ARADDR, output ARID, output ARLEN,
		output ARSIZE, output ARBURST, output ARLOCK, output ARCACHE, output ARPROT,
		output ARQOS, output ARREGION,
		
		input RVALID, output RREADY, input RDATA, input RLAST, input RID,
		input RRESP,
		
		input BVALID, output BREADY, input BID, input BRESP
	);
	
	modport slave (
		//input ACLK, input ARSTN,
		
		input AWVALID, output AWREADY,
		input AWADDR, input AWID, input AWLEN, input AWSIZE, input AWBURST,
		input AWLOCK, input AWCACHE, input AWPROT, input AWQOS, input AWREGION,
		
		input WVALID, output WREADY, input WDATA, input WSTRB, input WLAST,
		
		input ARVALID, output ARREADY, input ARADDR, input ARID, input ARLEN,
		input ARSIZE, input ARBURST, input ARLOCK, input ARCACHE, input ARPROT,
		input ARQOS, input ARREGION,
		
		output RVALID, input RREADY, output RDATA, output RLAST, output RID,
		output RRESP,
		
		output BVALID, input BREADY, output BID, output BRESP
	);
	
endinterface
