`default_nettype none

module cu_simple_instr_decode #(parameter ADDR_WIDTH=8,DATA_WIDTH=32) (
		data_interface.consumer raw_instr,
		pointer_interface.producer jump,
		pointer_interface.producer branch,
		instruction_interface.producer to_mib
	);
	localparam OP_BITS      = 2;
	localparam OP_MOVE      = 2'b00;
	localparam OP_IMMEDIATE = 2'b01;
	localparam OP_JUMP      = 2'b10;
	localparam OP_BRANCH    = 2'b11;
	
	wire   [OP_BITS-1:0] part_op;
	assign part_op = raw_instr.data[OP_BITS-1:0];
	wire   [ADDR_WIDTH-1:0] part_to_addr;
	assign part_to_addr = raw_instr.data[ADDR_WIDTH+OP_BITS-1:OP_BITS];
	wire   [ADDR_WIDTH-1:0] part_from_addr; // Overlaps with immediate.
	assign part_from_addr = raw_instr.data[(ADDR_WIDTH*2)+OP_BITS-1:ADDR_WIDTH+OP_BITS];
	wire   [DATA_WIDTH-ADDR_WIDTH-OP_BITS-1:0] part_immediate; // Overlaps with move from addr.
	assign part_immediate = raw_instr.data[DATA_WIDTH-1:ADDR_WIDTH+OP_BITS];
	wire   [DATA_WIDTH-OP_BITS-1:0] part_jump_dest;
	assign part_jump_dest = raw_instr.data[DATA_WIDTH-1:OP_BITS];
	
	wire is_move;
	assign is_move      = raw_instr.valid && (part_op == OP_MOVE);
	wire is_immediate;
	assign is_immediate = raw_instr.valid && (part_op == OP_IMMEDIATE);
	wire is_jump;
	assign is_jump      = raw_instr.valid && (part_op == OP_JUMP);
	wire is_branch;
	assign is_branch    = raw_instr.valid && (part_op == OP_BRANCH);
	
	assign to_mib.move_valid = is_move;
	assign to_mib.move_from = is_move ? part_from_addr : 0;
	assign to_mib.move_to = is_move ? part_to_addr : 0;
	
	assign to_mib.immediate_valid = is_immediate;
	assign to_mib.immediate_addr = is_immediate ? part_to_addr : 0;
	assign to_mib.immediate = is_immediate ?
	                          {{ADDR_WIDTH{1'b0}}, {2'b0}, part_immediate} : 0;
	
	assign jump.valid = is_jump;
	//assign jump.ptr = is_jump ? {2'b00, part_jump_dest} : 0;
	assign jump.ptr = is_jump ? {{(DATA_WIDTH-16){1'b0}}, part_jump_dest[15:0]} : 0;
	
	assign branch.valid = is_branch;
	assign branch.ptr = is_branch ? {2'b00, part_jump_dest} : 0;
	
	assign raw_instr.ack = (is_move && to_mib.move_ack)
	                       || (is_immediate && to_mib.immediate_ack)
	                       || (is_jump && jump.ack)
	                       || (is_branch && branch.ack);
endmodule
