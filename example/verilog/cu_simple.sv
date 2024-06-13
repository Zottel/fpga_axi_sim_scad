`default_nettype none

module cu_simple
	#(parameter ADDR_WIDTH=8, DATA_WIDTH=32) (
	input wire clock,
	input wire start,
	output wire done,
	output wire idle,
	mem_interface.requester instr_mem,
	data_interface.consumer branch_condition,
	instruction_interface.producer to_mib);
	
	reg running = 0;
	reg switched = 0; // Was running state switched this cycle?
	
	assign done = !running && switched;
	assign idle = !running;
	
	wire loop_detected;
	
	always @ (posedge clock) begin
		if (running && loop_detected) begin
			running <= 0;
			switched <= 1;
		end else if (start) begin
			running <= 1;
			switched <= 1;
		end else begin
			switched <= 0;
		end
	end
	
	pointer_interface #(.PTR_WIDTH(DATA_WIDTH)) jump();
	pointer_interface #(.PTR_WIDTH(DATA_WIDTH)) branch();
	
	data_interface  #(.DATA_WIDTH(DATA_WIDTH)) raw_instr();
	
	cu_simple_instr_fetch #(.ADDR_WIDTH(ADDR_WIDTH),.DATA_WIDTH(DATA_WIDTH))
	instr_fetch(
		.clock(clock),
		.enable(running),
		.reset(!running),
		.loop_detected(loop_detected),
		.instr_mem(instr_mem),
		.raw_instr(raw_instr),
		.jump(jump),
		.branch(branch),
		.branch_condition(branch_condition));
	
	cu_simple_instr_decode #(.ADDR_WIDTH(ADDR_WIDTH),.DATA_WIDTH(DATA_WIDTH))
	instr_decode(
		.raw_instr(raw_instr),
		.jump(jump),
		.branch(branch),
		.to_mib(to_mib));
	
	`ifdef FORMAL
		always @ (posedge clock) begin
			only_instruction_type_output_valid:
				assert (!(branch.valid && jump.valid)
				        && !(branch.valid && to_mib.move_valid)
				        && !(branch.valid && to_mib.immediate_valid)
				        && !(jump.valid && to_mib.move_valid)
				        && !(jump.valid && to_mib.immediate_valid)
				        && !(to_mib.move_valid && to_mib.immediate_valid));
			at_least_one_instruction_type_valid:
				assert (!raw_instr.valid || branch.valid || jump.valid
				        || to_mib.move_valid || to_mib.immediate_valid);
				assert (!raw_instr.valid || branch.valid || jump.valid
				        || to_mib.move_valid || to_mib.immediate_valid);
		end
	`endif
endmodule

