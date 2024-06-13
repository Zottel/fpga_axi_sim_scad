`default_nettype none

module mib_simple_input_demux_8 (input wire [4-1:0] move_buffer_addr, instruction_output_interface.consumer output_instr, instruction_output_interface.producer output_buffer_0, instruction_output_interface.producer output_buffer_1, instruction_output_interface.producer output_buffer_2, instruction_output_interface.producer output_buffer_3, instruction_output_interface.producer output_buffer_4, instruction_output_interface.producer output_buffer_5, instruction_output_interface.producer output_buffer_6, instruction_output_interface.producer output_buffer_7);
  assign output_buffer_0.move_to = (move_buffer_addr == 4'd0) ? output_instr.move_to : 0;
  assign output_buffer_0.move_valid = (move_buffer_addr == 4'd0) ? output_instr.move_valid : 0;
  assign output_buffer_1.move_to = (move_buffer_addr == 4'd1) ? output_instr.move_to : 0;
  assign output_buffer_1.move_valid = (move_buffer_addr == 4'd1) ? output_instr.move_valid : 0;
  assign output_buffer_2.move_to = (move_buffer_addr == 4'd2) ? output_instr.move_to : 0;
  assign output_buffer_2.move_valid = (move_buffer_addr == 4'd2) ? output_instr.move_valid : 0;
  assign output_buffer_3.move_to = (move_buffer_addr == 4'd3) ? output_instr.move_to : 0;
  assign output_buffer_3.move_valid = (move_buffer_addr == 4'd3) ? output_instr.move_valid : 0;
  assign output_buffer_4.move_to = (move_buffer_addr == 4'd4) ? output_instr.move_to : 0;
  assign output_buffer_4.move_valid = (move_buffer_addr == 4'd4) ? output_instr.move_valid : 0;
  assign output_buffer_5.move_to = (move_buffer_addr == 4'd5) ? output_instr.move_to : 0;
  assign output_buffer_5.move_valid = (move_buffer_addr == 4'd5) ? output_instr.move_valid : 0;
  assign output_buffer_6.move_to = (move_buffer_addr == 4'd6) ? output_instr.move_to : 0;
  assign output_buffer_6.move_valid = (move_buffer_addr == 4'd6) ? output_instr.move_valid : 0;
  assign output_buffer_7.move_to = (move_buffer_addr == 4'd7) ? output_instr.move_to : 0;
  assign output_buffer_7.move_valid = (move_buffer_addr == 4'd7) ? output_instr.move_valid : 0;
assign output_instr.move_ack = ((move_buffer_addr == 4'd0) && output_buffer_0.move_ack)||((move_buffer_addr == 4'd1) && output_buffer_1.move_ack)||((move_buffer_addr == 4'd2) && output_buffer_2.move_ack)||((move_buffer_addr == 4'd3) && output_buffer_3.move_ack)||((move_buffer_addr == 4'd4) && output_buffer_4.move_ack)||((move_buffer_addr == 4'd5) && output_buffer_5.move_ack)||((move_buffer_addr == 4'd6) && output_buffer_6.move_ack)||((move_buffer_addr == 4'd7) && output_buffer_7.move_ack);
endmodule
