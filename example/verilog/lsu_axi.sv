// Simple LSU that just connects data_interface and mem_interface.
// Has 4 opcodes:
// - 0: read_nop: Consumes address but does nothing.
// - 1: write_nop: Consumes address and value but does nothing.
// - 2: read: Consumes address and places memory value at that
//            position into result.
// - 3: write: Consumes address and value. Writes value to memory address.
//             No result.

`default_nettype none

module lsu_axi
	#(parameter DATA_WIDTH=32,
		MEMADDR_WIDTH=64,
		OP_WIDTH=2,
		LSU_OP_READ_NOP = 2'd00,
		LSU_OP_WRITE_NOP = 2'd01,
		LSU_OP_READ = 2'd02,
		LSU_OP_WRITE = 2'd03)
	(
		input wire clock,
		
		axi_interface.master axi,
		
		data_interface.consumer op,
		data_interface.consumer address,
		data_interface.consumer value,
		
		data_interface.producer result
	);
	
	wire [OP_WIDTH-1:0] opcode;
	assign opcode = op.data[OP_WIDTH-1:0];
	wire [(DATA_WIDTH-OP_WIDTH)-1:0] count;
	assign count = op.data[DATA_WIDTH-1:OP_WIDTH];
	
	wire [2:0] size;
	if (DATA_WIDTH == 32) begin
		assign size = 3'b010;
	end else if (DATA_WIDTH == 64) begin
		assign size = 3'b011;
	end else begin
		$error($sformatf(
			"This dummy supports 32 or 64 bit data width. Is %d.",
			DATA_WIDTH
		));
	end
	
	// Default settings from Xilinx Vitis RTL kernel example.
	// https://github.com/Xilinx/SDAccel_Examples/
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
	
	// Same ID for all transactions. Should not be re-ordered.
	assign axi.AWID    = 1'b0;    // Write transaction ID 0.
	assign axi.ARID    = 1'b0;    // Read transaction ID 0.
	
	wire write_ready = address.valid && op.valid
	                   && opcode == LSU_OP_WRITE;
	assign axi.AWVALID = write_ready;
	assign axi.AWADDR = write_ready ? (address.data * (DATA_WIDTH / 8)) : 0;
	/* verilator lint_off WIDTH */
	assign axi.AWSIZE = size;
	/* verilator lint_on WIDTH */
	assign axi.AWLEN   = 0; // One beat.
	// TODO: assign X = axi.AWREADY;
	
	// This channel is mostly independent, connect to our value buffer.
	// TODO: Only after write address? CHECK SPEC.
	assign axi.WVALID = value.valid;
	assign axi.WDATA = value.data;
	/* verilator lint_off WIDTH */
	assign axi.WSTRB = {(DATA_WIDTH/8){1'b1}}; // All bytes valid.
	/* verilator lint_on WIDTH */
	assign axi.WLAST = 1;
	assign value.ack = value.valid && axi.WREADY;
	
	
	wire read_ready = address.valid && op.valid
	                  && opcode == {LSU_OP_READ};
	assign axi.ARVALID = read_ready;
	assign axi.ARADDR = read_ready ? (address.data * (DATA_WIDTH / 8)) : 0;
	/* verilator lint_off WIDTH */
	assign axi.ARSIZE = size;
	/* verilator lint_on WIDTH */
	assign axi.ARLEN = 0; // burst length: one beat.
	
	
	assign op.ack = (write_ready && axi.AWREADY) || (read_ready && axi.ARREADY);
	assign address.ack = (write_ready && axi.AWREADY)
	                     || (read_ready && axi.ARREADY);
	
	// AXI read result to output buffer.
	assign result.valid = axi.RVALID;
	assign result.data = axi.RDATA;
	assign axi.RREADY = result.ack;
	
	// Just ack every write response. We have no way to interact with these.
	assign axi.BREADY = 1;
	
	`ifdef FORMAL
		
	`endif
endmodule
