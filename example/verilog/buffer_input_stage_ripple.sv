`default_nettype none

module buffer_input_stage_ripple
	#(parameter ADDR_WIDTH=8, DATA_WIDTH=32) (
	input wire clock,
	message_interface_nonblocking.consumer dtn,
	message_interface_nonblocking.producer dtn_forward,
	
	instruction_input_interface.consumer cu,
	instruction_input_interface.producer cu_forward,
	
	buffer_line_interface.producer line_out,
	buffer_line_interface.consumer line_in
);
	// Ripple forward unmatched message.
	reg [ADDR_WIDTH-1:0] message_addr = 0;
	reg [DATA_WIDTH-1:0] message_data = 0;
	reg message_valid = 0;
	// Current line tag and values.
	reg [ADDR_WIDTH-1:0] line_addr = 0;
	reg line_addr_valid = 0;
	reg [DATA_WIDTH-1:0] line_data = 0;
	reg line_data_valid = 0;
	
	wire shifting = line_out.ack & line_addr_valid;
	
	// Decision signals.
	wire consume_dtn_for_current_state =
		dtn.valid && line_addr_valid
		&& !line_data_valid
		&& (line_addr == dtn.from);
	wire consume_dtn_for_next_state =
		shifting && dtn.valid && !consume_dtn_for_current_state
		&& line_in.addr_valid & !line_in.data_valid
		&& (line_in.addr == dtn.from);
	wire consume_dtn = consume_dtn_for_current_state
	                   | consume_dtn_for_next_state;
	wire space_for_address = (shifting &(!line_in.addr_valid))
	                         | (!shifting & !line_addr_valid);
	wire consume_cu_address = cu.move_valid & space_for_address;
	wire consume_cu_immediate = cu.immediate_valid & space_for_address;
	
	always @ (posedge clock)
	begin
		if(dtn.valid & !consume_dtn) begin
			message_data <= dtn.data;
			message_addr <= dtn.from;
			message_valid <= dtn.valid;
		end else begin
			message_data <= 0;
			message_addr <= 0;
			message_valid <= 0;
		end
		
		
		//line_data <= 4;
		line_data <= consume_cu_immediate ? cu.immediate :
		             (shifting
		              ? (consume_dtn_for_next_state ? dtn.data : line_in.data)
		              : (consume_dtn_for_current_state ? dtn.data : line_data));
		line_data_valid <= consume_cu_immediate |
		                   (shifting
		                    ? (consume_dtn_for_next_state | line_in.data_valid)
		                    : (consume_dtn_for_current_state | line_data_valid));
		
		line_addr <= consume_cu_address ? cu.move_from :
		             (shifting ? line_in.addr : line_addr);
		line_addr_valid <= consume_cu_address | consume_cu_immediate |
		                   (shifting ? line_in.addr_valid : line_addr_valid);
	end
	
	// Shift signal forward.
	assign line_in.ack = line_out.ack;
	// Line content forwarding.
	assign line_out.addr = line_addr;
	assign line_out.addr_valid = line_addr_valid;
	assign line_out.data = consume_dtn_for_current_state
	                       ? dtn.data : line_data;
	assign line_out.data_valid = consume_dtn_for_current_state | line_data_valid;
	assign line_out.data_just_matched = consume_dtn_for_current_state;
	
	// Forwarding signals for data messages.
	assign dtn_forward.from = message_valid ? message_addr : 0;
	assign dtn_forward.to = 0; // Not useful inside buffer.
	assign dtn_forward.data = message_data;
	assign dtn_forward.valid = message_valid;
	
	// Forwarding signals for control instructions.
	assign cu_forward.immediate = cu.immediate;
	assign cu_forward.immediate_valid = cu.immediate_valid & !consume_cu_immediate;
	assign cu_forward.move_from     = cu.move_from;
	assign cu_forward.move_valid = cu.move_valid & !consume_cu_address;
	assign cu.move_ack = space_for_address | cu_forward.move_ack;
	assign cu.immediate_ack = space_for_address | cu_forward.immediate_ack;
endmodule
