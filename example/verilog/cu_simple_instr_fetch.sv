`default_nettype none

module cu_simple_instr_fetch #(parameter ADDR_WIDTH=8,DATA_WIDTH=32) (
	input wire clock,
	input wire enable,
	input wire reset,
	output wire loop_detected, // Infinite loop detected, used for termination.
	mem_interface.requester instr_mem,
	data_interface.producer raw_instr,
	pointer_interface.consumer jump,
	pointer_interface.consumer branch,
	data_interface.consumer branch_condition);
	
	reg [DATA_WIDTH-1:0] pc = 0;
	
	wire [DATA_WIDTH-1:0] next_pc;
	// Decisions for PC changes:
	//assign next_pc = jump.valid ? jump.ptr
	//                 :((branch.valid && (branch_condition.data != 0))
	//                   ? branch.ptr
	//                   :(pc + 1));
	assign next_pc =
		reset ? 0
		: !instr_mem.read_data_valid ? pc // No change until memory delivers.
		: jump.valid ? jump.ptr // 
		: branch.valid ?
			(
				!branch_condition.valid ? pc
				: (branch_condition.data == 0) ? (pc + 1)
				: branch.ptr
			)
		: (pc + 1);
	
	wire use_next_pc;
	assign use_next_pc = raw_instr.ack || reset;
	// assign use_next_pc = jump.valid || (branch.valid && branch_condition.valid)
	//                      || (!jump.valid && !branch.valid && raw_instr.ack);
	
	assign jump.ack = jump.valid;
	
	assign branch_condition.ack = branch.valid && branch_condition.valid;
	assign branch.ack = branch.valid && branch_condition.valid;
	
	// Detect an infinite loop used to indicate program termination.
	assign loop_detected = jump.valid && (jump.ptr == pc);
	
	always @ (posedge clock) begin
		if (use_next_pc) begin
			pc <= next_pc;
		end
	end
	
	// Never writes.
	assign instr_mem.write_address = 0;
	assign instr_mem.write_data = 0;
	assign instr_mem.write_valid = 0;
	
	// Actual read.
	assign instr_mem.read_address = use_next_pc ? next_pc : pc;
	assign instr_mem.read_address_valid = enable;
	assign raw_instr.data = instr_mem.read_data;
	assign raw_instr.valid = instr_mem.read_data_valid && enable;
	
	`ifdef FORMAL
		always @ (posedge clock) begin
			memory_stable_data_during_read:
				assume (
					// If there is a valid read address that remains stable for two
					// cycles...
					!($past(instr_mem.read_address_valid)
						&& instr_mem.read_address_valid
				    && ($past(instr_mem.read_address) == instr_mem.read_address))
				  || (
					// ... then two conditions must hold:
						// 1) Once the data is valid, it remains valid.
						( !$past(instr_mem.read_data_valid || instr_mem.read_data_valid)
						&&
						// 2) If the data is valid, then it must not change.
						( !($past(instr_mem.read_data_valid) == instr_mem.read_data_valid)
							|| $past(instr_mem.read_data) == instr_mem.read_data)
					)));
		end
	`endif
endmodule
