`default_nettype none

module mib_simple_fsm(
	input  wire clock,
	input  wire cu_valid,
	output wire cu_ack,
	output wire src_valid,
	input  wire src_ack,
	output wire dest_valid,
	input  wire dest_ack);

	// Remember partial ack, i.e. only source or destination are ready.
	reg old_dest_ack = 0;
	reg old_done = 0;
	
	// When a message was acknowledged for only the source or the destination,
	// that endpoint must not receive this message another time.
	assign src_valid = (dest_ack || (old_dest_ack && !old_done)) && cu_valid;
	assign dest_valid = cu_valid && (!old_dest_ack || old_done );
	
	assign cu_ack = cu_valid && src_ack && (dest_ack || (old_dest_ack && !old_done));
	
	always @ (posedge clock) begin
		old_dest_ack <= cu_valid && (dest_ack || (old_dest_ack && !old_done));
		old_done <= cu_valid && src_ack && (dest_ack || old_dest_ack);
	end
	
	`ifdef FORMAL
		always @ (posedge clock) begin
			assume (!$past(cu_valid));
		end
	`endif
endmodule
