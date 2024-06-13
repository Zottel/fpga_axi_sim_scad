// AXI standard writers: Please move away from master/slave terminology.
// Requester/responder or similar are just as nice and a lot less burdened
// by historic BS.

`default_nettype none

module axi_lite_control_slave
#(parameter
	ADDR_WIDTH=12,
	DATA_WIDTH=32,
	ARG_WORDS=32
) (
	input wire ap_clk,
	input wire ap_rst_n,
	axi_lite_interface.slave axi,
	
	// Control signals required for Vitis interop.
	output wire start,
	input wire done,
	input wire idle,
	
	// Parameters given to Vitis RTL Kernel by host.
	output wire [(DATA_WIDTH * ARG_WORDS)-1:0] args
	// (Combined into one long bitvector for portability across synthesis tools.)
);
	localparam BYTES_PER_WORD = DATA_WIDTH / 8;
	localparam AXI_OKAY = 0, AXI_EXOKAY = 1, AXI_SLVERR = 2, AXI_DECERR = 3;
	
	axi_lite_interface #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH))
		axi_buffered();
	
	axi_lite_buffer #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH))
		axi_buffer(.ap_clk(ap_clk), .to_master(axi), .to_slave(axi_buffered));
	
	wire [ADDR_WIDTH-1:0] args_offset;
	wire [ADDR_WIDTH-1:0] args_limit;
	assign args_offset = {{(ADDR_WIDTH-5){1'b0}}, 5'h10};
	/* verilator lint_off WIDTH */
	assign args_limit = (args_offset + (ARG_WORDS * BYTES_PER_WORD));
	/* verilator lint_on WIDTH */
	
	wire is_args_read;
	wire is_args_write;
	//if (args_limit == 0) begin
	if ($clog2('h10 + (ARG_WORDS * BYTES_PER_WORD)) > ADDR_WIDTH) begin
		assign is_args_read = (axi_buffered.ARADDR >= args_offset);
		assign is_args_write = (axi_buffered.AWADDR >= args_offset);
	end else begin
		assign is_args_read = (axi_buffered.ARADDR >= args_offset)
		                      && (axi_buffered.ARADDR < args_limit);
		assign is_args_write = (axi_buffered.AWADDR >= args_offset)
		                       && (axi_buffered.AWADDR < args_limit);
	end
	
	wire [ADDR_WIDTH-1:0] args_read_index;
	wire [ADDR_WIDTH-1:0] args_write_index;
	assign args_read_index = (axi_buffered.ARADDR - args_offset) / BYTES_PER_WORD;
	assign args_write_index = (axi_buffered.AWADDR - args_offset) / BYTES_PER_WORD;
	
	// Turn AXI write strobe into a mask. Roughly modeled after code of Xilinx
	// Sample.
	wire [(DATA_WIDTH/8)-1:0] wstrb;
	assign wstrb = axi_buffered.WSTRB;
	wire [DATA_WIDTH-1:0] wmask;
	if (DATA_WIDTH == 32) begin
		assign wmask =
			{ {8{wstrb[3]}}, {8{wstrb[2]}}, {8{wstrb[1]}}, {8{wstrb[0]}} };
	end else if (DATA_WIDTH == 64) begin
		assign wmask =
			{ {8{wstrb[7]}}, {8{wstrb[6]}}, {8{wstrb[5]}}, {8{wstrb[4]}},
			  {8{wstrb[3]}}, {8{wstrb[2]}}, {8{wstrb[1]}}, {8{wstrb[0]}} };
	end else begin
		$error($sformatf(
			"Our Vitis AXI lite control registers 32 or 64 bit data width. Is %d.",
			ADDR_WIDTH
		));
	end
	
	reg [(DATA_WIDTH * (ARG_WORDS))-1:0] args_reg = 0;
	assign args = args_reg;
	
	// Status is easier to handle as individual bits.
	reg start_reg = 0;
	reg done_reg  = 0;
	reg idle_reg  = 1;
	
	assign start  = start_reg;
	wire [DATA_WIDTH-1:0] status =
		{{(DATA_WIDTH-3){1'b0}}, idle_reg, done_reg, start_reg};
	
	// Accept writes only when both address and data are present.
	wire perform_write = axi_buffered.AWVALID && axi_buffered.WVALID && axi_buffered.BREADY;
	assign axi_buffered.AWREADY = perform_write;
	assign axi_buffered.WREADY  = perform_write;
	assign axi_buffered.BVALID  = perform_write;
	/* verilator lint_off WIDTH */
	assign axi_buffered.BRESP  = !perform_write ? 0
	                    : axi_buffered.AWADDR < args_offset ? AXI_OKAY
	                    : is_args_write ? AXI_OKAY
	                    : AXI_SLVERR;
	/* verilator lint_on WIDTH */
	
	// Handle reads without local state.
	assign axi_buffered.ARREADY = axi_buffered.RREADY;
	assign axi_buffered.RVALID  = axi_buffered.ARVALID;
	
	/* verilator lint_off WIDTH */
	assign axi_buffered.RDATA = !axi_buffered.ARVALID ? 0
	                   : (axi_buffered.ARADDR == 0) ? status
	                   : (axi_buffered.ARADDR < args_offset) ? 0
	                   : is_args_read ? args_reg[DATA_WIDTH*args_read_index +: DATA_WIDTH]
	                   : 0;
	/* verilator lint_on WIDTH */
	
	/* verilator lint_off WIDTH */
	assign axi_buffered.RRESP = !axi_buffered.ARVALID ? 0
	                   : (axi_buffered.ARADDR < args_offset) ? AXI_OKAY
	                   : is_args_read ? AXI_OKAY
	                   : AXI_SLVERR;
	/* verilator lint_on WIDTH */
	
	always @ (posedge ap_clk) begin
		start_reg <= (perform_write && axi_buffered.AWADDR == 0 && axi_buffered.WDATA[0]);
		
		// Done until cleared by read.
		done_reg <=
			done || (done_reg && !(axi_buffered.ARREADY && axi_buffered.ARVALID && axi_buffered.ARADDR == 0));
		
		// Idle from done to start.
		idle_reg <= done_reg || (idle_reg && !start_reg);
		
		// Write to arguments:
		/* verilator lint_off WIDTH */
		if (perform_write && is_args_write) begin
			//args_reg[DATA_WIDTH*(axi_buffered.AWADDR-16) +: DATA_WIDTH] <= axi_buffered.WDATA;
			
			//args_reg[DATA_WIDTH*(axi_buffered.AWADDR-16) +: DATA_WIDTH]
			//	<= (args_reg[DATA_WIDTH*(axi_buffered.AWADDR-16) +: DATA_WIDTH] | ~wmask)
			//	   | (axi_buffered.WDATA & wmask);

			args_reg[DATA_WIDTH*args_write_index +: DATA_WIDTH]
				<= (args_reg[DATA_WIDTH*args_write_index +: DATA_WIDTH] | ~wmask)
				   | (axi_buffered.WDATA & wmask);
		end
		/* verilator lint_on WIDTH */
	end
endmodule
