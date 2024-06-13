`default_nettype none

module mib_14_8 (input wire clock, instruction_interface.consumer cu, instruction_input_interface.producer input_buffer_0, instruction_input_interface.producer input_buffer_1, instruction_input_interface.producer input_buffer_2, instruction_input_interface.producer input_buffer_3, instruction_input_interface.producer input_buffer_4, instruction_input_interface.producer input_buffer_5, instruction_input_interface.producer input_buffer_6, instruction_input_interface.producer input_buffer_7, instruction_input_interface.producer input_buffer_8, instruction_input_interface.producer input_buffer_9, instruction_input_interface.producer input_buffer_10, instruction_input_interface.producer input_buffer_11, instruction_input_interface.producer input_buffer_12, instruction_input_interface.producer input_buffer_13, instruction_output_interface.producer output_buffer_0, instruction_output_interface.producer output_buffer_1, instruction_output_interface.producer output_buffer_2, instruction_output_interface.producer output_buffer_3, instruction_output_interface.producer output_buffer_4, instruction_output_interface.producer output_buffer_5, instruction_output_interface.producer output_buffer_6, instruction_output_interface.producer output_buffer_7);
  instruction_input_interface #(.ADDR_WIDTH(4), .DATA_WIDTH(64)) to_input();
  instruction_output_interface #(.ADDR_WIDTH(4), .DATA_WIDTH(64)) to_output();
  mib_simple_fsm fsm(
    .clock(clock),
    .cu_valid(cu.move_valid),
    .cu_ack(cu.move_ack),
    .src_valid(to_output.move_valid),
    .src_ack(to_output.move_ack),
    .dest_valid(to_input.move_valid),
    .dest_ack(to_input.move_ack));
  
  // INPUT:
  assign to_input.move_from = cu.move_from;
  assign to_input.immediate = cu.immediate;
  assign to_input.immediate_valid = cu.immediate_valid;
  assign cu.immediate_ack = to_input.immediate_ack;
  mib_simple_output_demux_14 demux_in(
    .move_buffer_addr(cu.move_to),
    .immediate_buffer_addr(cu.immediate_addr),
    .input_instr(to_input),
    .input_buffer_0(input_buffer_0), .input_buffer_1(input_buffer_1), .input_buffer_2(input_buffer_2), .input_buffer_3(input_buffer_3), .input_buffer_4(input_buffer_4), .input_buffer_5(input_buffer_5), .input_buffer_6(input_buffer_6), .input_buffer_7(input_buffer_7), .input_buffer_8(input_buffer_8), .input_buffer_9(input_buffer_9), .input_buffer_10(input_buffer_10), .input_buffer_11(input_buffer_11), .input_buffer_12(input_buffer_12), .input_buffer_13(input_buffer_13));

// OUTPUT:
assign to_output.move_to = cu.move_to;
  mib_simple_input_demux_8 demux_out(
    .move_buffer_addr(cu.move_from),
    .output_instr(to_output),
    .output_buffer_0(output_buffer_0), .output_buffer_1(output_buffer_1), .output_buffer_2(output_buffer_2), .output_buffer_3(output_buffer_3), .output_buffer_4(output_buffer_4), .output_buffer_5(output_buffer_5), .output_buffer_6(output_buffer_6), .output_buffer_7(output_buffer_7));
endmodule
