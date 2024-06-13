`default_nettype none

module cache_readonly_dm
#(ADDR_WIDTH=32,
  DATA_WIDTH=32,
  LINE_WIDTH=256,
  LINE_COUNT=16)
( input wire clock,
	mem_interface.responder cpu, // Interface to CPU.
  axi_interface.master axi);

	// Check that line count is a power of two, since we need that for correct
	// address decoding and matching.
	// https://graphics.stanford.edu/~seander/bithacks.html#DetermineIfPowerOf2
	if ((LINE_COUNT & (LINE_COUNT - 1)) != 0)
		$error($sformatf("Parameter LINE_COUNT is not a power of two: %0d.",
		                 LINE_COUNT));
	
	if (LINE_WIDTH < DATA_WIDTH)
		$error($sformatf("Line width (%d) is smaller than data width(%d).",
		                 LINE_WIDTH, DATA_WIDTH));
	
	// Bit width calculations:
	localparam FLAGS_WIDTH = 1; // Only valid for now.
	localparam LINE_ADDR_WIDTH = $clog2(LINE_COUNT);
	// Offset of word in line:
	localparam OFFSET_WIDTH = $clog2(LINE_WIDTH / DATA_WIDTH);
	
	localparam TAG_WIDTH = ADDR_WIDTH - LINE_ADDR_WIDTH - OFFSET_WIDTH;
	localparam FULL_LINE_WIDTH = FLAGS_WIDTH + TAG_WIDTH + LINE_WIDTH;
	
	if (ADDR_WIDTH < $clog2(LINE_WIDTH * LINE_COUNT / DATA_WIDTH))
		$error($sformatf(
			"Total addressable memory (%d bit addr) is smaller than cache (%d bit addr).",
	    ADDR_WIDTH, $clog2(LINE_WIDTH * LINE_COUNT / DATA_WIDTH)
		));
	
	if (FULL_LINE_WIDTH < LINE_WIDTH)
		$error($sformatf("Internal line width (%d) is smaller than line width(%d).",
		                 FULL_LINE_WIDTH, LINE_WIDTH));
	
	// $error($sformatf(
	// 	"ADDR_WIDTH: %d, DATA_WIDTH: %d, LINE_WIDTH:%d, LINE_COUNT: %d",
	// 	ADDR_WIDTH, DATA_WIDTH, LINE_WIDTH, LINE_COUNT
	// ));
	// $error($sformatf(
	// 	"FLAGS_WIDTH: %d, LINE_ADDR_WIDTH: %d, OFFSET_WIDTH: %d, TAG_WIDTH: %d",
	// 	FLAGS_WIDTH, LINE_ADDR_WIDTH, OFFSET_WIDTH, TAG_WIDTH
	// ));
	
	reg [FULL_LINE_WIDTH-1:0] contents [LINE_COUNT];
	
	integer i;
	initial begin
		for(i = 0; i < LINE_COUNT; i = i + 1) begin
			contents[i] = 0;
		end
	end
	
	// Cache state and result buffers.
	reg [FULL_LINE_WIDTH-1:0] read_contents = 0;
	reg [ADDR_WIDTH-1:0] read_addr = 0;
	reg read_valid = 0;
	
	// Split read contents into flags, tag and data.
	wire [FLAGS_WIDTH-1:0] read_flags =
		read_contents[FULL_LINE_WIDTH-1:FULL_LINE_WIDTH-FLAGS_WIDTH];
	wire read_line_valid = read_flags[0];
	wire [TAG_WIDTH-1:0] read_tag =
		read_contents[TAG_WIDTH-1+LINE_WIDTH:LINE_WIDTH];
	wire [OFFSET_WIDTH-1:0] read_offset = read_addr[OFFSET_WIDTH-1:0];
	wire [LINE_WIDTH-1:0] read_line = read_contents[LINE_WIDTH-1:0];
	
	wire read_tag_match =
		read_tag == read_addr[ADDR_WIDTH-1:LINE_ADDR_WIDTH+OFFSET_WIDTH];
	
	// Outputs.
	assign cpu.read_data_valid = read_tag_match && read_line_valid && read_valid;
	assign cpu.write_ack = 0;
	
	// Get correct word for address from line.
	// +: is verilog syntax for "constant-width slice at certain point".
	assign cpu.read_data = read_line[DATA_WIDTH*read_offset +: DATA_WIDTH];
	
	// State: Is a memory fetch in progress?
	reg fetching = 0;
	reg storing_response = 0;
	
	//wire [(ADDR_WIDTH - $clog2(DATA_WIDTH/8))-1:0] mem_req_addr =
	//	{cpu.read_address[(ADDR_WIDTH - $clog2(DATA_WIDTH/8))-1:($clog2(DATA_WIDTH/8))], {($clog2(DATA_WIDTH/8)){1'b0}} };
	wire [ADDR_WIDTH-1:0] mem_req_addr;
	assign mem_req_addr =
		{read_addr[ADDR_WIDTH-$clog2(DATA_WIDTH/8)-1:0],
		 {($clog2(DATA_WIDTH/8)){1'b0}} };
	wire mem_req_valid = !fetching && read_valid && !storing_response &&
		(!read_line_valid || !read_tag_match);
	wire mem_req_ack;
	wire [LINE_WIDTH-1:0] mem_resp_data;
	wire mem_resp_valid;
	wire mem_resp_ack = 1;
	
	//#(.DATA_WIDTH(LINE_WIDTH), .ADDR_WIDTH(ADDR_WIDTH+$clog2(8)))
	cache_axi_fetcher
		#(.DATA_WIDTH(LINE_WIDTH), .ADDR_WIDTH(64))
		fetcher (
			.clock(clock),
			/* verilator lint_off WIDTH */
			.req_addr(mem_req_addr),
			/* verilator lint_on WIDTH */
			.req_valid(mem_req_valid),
			.req_ack(mem_req_ack),
			.resp_data(mem_resp_data),
			.resp_valid(mem_resp_valid),
			.resp_ack(mem_resp_ack),
			.axi(axi)
		);
	// TODO: submodule
	
	always @ (posedge clock) begin
		read_valid <= cpu.read_address_valid;
		if (cpu.read_address_valid) begin
			read_contents <=
				contents[cpu.read_address[LINE_ADDR_WIDTH+OFFSET_WIDTH-1:OFFSET_WIDTH]];
			read_addr <= cpu.read_address;
		end else begin
			read_contents <= 0;
			read_addr <= 0;
		end
		
		if (mem_resp_valid) begin
			storing_response <= 1;
			contents[read_addr[LINE_ADDR_WIDTH+OFFSET_WIDTH-1:OFFSET_WIDTH]]
				<= {
					1'b1, // flag: line is valid
					read_addr[ADDR_WIDTH-1:LINE_ADDR_WIDTH+OFFSET_WIDTH], // tag
					mem_resp_data // Line data
				};
		end else begin
			storing_response <= 0;
		end
		
		// Fetching is valid while request is in flight.
		fetching <= (fetching || (mem_req_valid && mem_req_ack)) && !mem_resp_valid;
	end
	
	`ifdef FORMAL
		reg [31:0] cycle = 0;
		// TODO: Add assumptions for memory behaviour.
		always @ (posedge clock) begin
			cycle <= cycle + 1;
			
			run_for_some_time:
				cover (cycle == 24);
			
			assume(!axi.RVALID || (axi.RDATA == 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f));
			//assume((axi.RDATA == 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f));
			assume ((cpu.read_address*2) > cycle
				&& (cpu.read_address*2) < (cycle + 8));
			assume (cycle < 2 || $past(cpu.read_address_valid) || cpu.read_address_valid);
			assume (cycle < 2 || $past(!cpu.read_address_valid) || $past(cpu.read_data_valid) || cpu.read_address_valid);
			
			//either_fetching_or_delivering:
			//	assert (!$past(cpu.read_address_valid) || (cpu.read_data_valid || fetching));
			
			only_read_data:
			assert (!cpu.read_data_valid
				|| ($past(!cpu.read_address_valid || cpu.read_address % 8 == 7) && cpu.read_data == 32'h00010203)
				|| ($past(!cpu.read_address_valid || cpu.read_address % 8 == 6) && cpu.read_data == 32'h04050607)
				|| ($past(!cpu.read_address_valid || cpu.read_address % 8 == 5) && cpu.read_data == 32'h08090a0b)
				|| ($past(!cpu.read_address_valid || cpu.read_address % 8 == 4) && cpu.read_data == 32'h0c0d0e0f)
				|| ($past(!cpu.read_address_valid || cpu.read_address % 8 == 3) && cpu.read_data == 32'h10111213)
				|| ($past(!cpu.read_address_valid || cpu.read_address % 8 == 2) && cpu.read_data == 32'h14151617)
				|| ($past(!cpu.read_address_valid || cpu.read_address % 8 == 1) && cpu.read_data == 32'h18191a1b)
				|| ($past(!cpu.read_address_valid || cpu.read_address % 8 == 0) && cpu.read_data == 32'h1c1d1e1f));
			
			can_solve_requests:
				cover (cpu.read_data_valid);
			
			can_match_tag:
				cover (read_tag_match);
		end
	`endif
endmodule
