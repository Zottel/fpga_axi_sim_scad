`default_nettype none

module processor(
  input wire clock,
  input wire start,
  output wire done,
  output wire idle,
  axi_interface.master mem_progmem,
  axi_interface.master mem_gmem
);

wire rst = 0;
  instruction_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) cu_to_mib();

  instruction_input_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) mib_to_in0();
  instruction_input_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) mib_to_in1();
  instruction_input_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) mib_to_in2();
  instruction_input_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) mib_to_in3();
  instruction_input_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) mib_to_in4();
  instruction_input_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) mib_to_in5();
  instruction_input_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) mib_to_in6();
  instruction_input_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) mib_to_in7();
  instruction_input_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) mib_to_in8();
  instruction_input_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) mib_to_in9();
  instruction_input_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) mib_to_in10();
  instruction_input_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) mib_to_in11();
  instruction_input_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) mib_to_in12();
  instruction_input_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) mib_to_in13();

  instruction_output_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) mib_to_out0();
  instruction_output_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) mib_to_out1();
  instruction_output_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) mib_to_out2();
  instruction_output_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) mib_to_out3();
  instruction_output_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) mib_to_out4();
  instruction_output_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) mib_to_out5();
  instruction_output_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) mib_to_out6();
  instruction_output_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) mib_to_out7();

  mib_14_8 mib(.clock(clock),.cu(cu_to_mib),.input_buffer_0(mib_to_in0),.input_buffer_1(mib_to_in1),.input_buffer_2(mib_to_in2),.input_buffer_3(mib_to_in3),.input_buffer_4(mib_to_in4),.input_buffer_5(mib_to_in5),.input_buffer_6(mib_to_in6),.input_buffer_7(mib_to_in7),.input_buffer_8(mib_to_in8),.input_buffer_9(mib_to_in9),.input_buffer_10(mib_to_in10),.input_buffer_11(mib_to_in11),.input_buffer_12(mib_to_in12),.input_buffer_13(mib_to_in13),.output_buffer_0(mib_to_out0),.output_buffer_1(mib_to_out1),.output_buffer_2(mib_to_out2),.output_buffer_3(mib_to_out3),.output_buffer_4(mib_to_out4),.output_buffer_5(mib_to_out5),.output_buffer_6(mib_to_out6),.output_buffer_7(mib_to_out7));

  message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_in0();
  message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_in1();
  message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_in2();
  message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_in3();
  message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_in4();
  message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_in5();
  message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_in6();
  message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_in7();
  message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_in8();
  message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_in9();
  message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_in10();
  message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_in11();
  message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_in12();
  message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_in13();
  message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_in14();
  message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_in15();

  message_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_out0();
  message_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_out1();
  message_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_out2();
  message_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_out3();
  message_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_out4();
  message_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_out5();
  message_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_out6();
  message_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_out7();
  message_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_out8();
  message_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_out9();
  message_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_out10();
  message_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_out11();
  message_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_out12();
  message_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_out13();
  message_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_out14();
  message_interface #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) msg_out15();

combined_TNT_BIN_HC0_JaSJ17_68_16_0_pipelined_static_arbiter_16 dtn(.clock(clock), .out0(msg_in0), .out1(msg_in1), .out2(msg_in2), .out3(msg_in3), .out4(msg_in4), .out5(msg_in5), .out6(msg_in6), .out7(msg_in7), .out8(msg_in8), .out9(msg_in9), .out10(msg_in10), .out11(msg_in11), .out12(msg_in12), .out13(msg_in13), .out14(msg_in14), .out15(msg_in15), .in0(msg_out0), .in1(msg_out1), .in2(msg_out2), .in3(msg_out3), .in4(msg_out4), .in5(msg_out5), .in6(msg_out6), .in7(msg_out7), .in8(msg_out8), .in9(msg_out9), .in10(msg_out10), .in11(msg_out11), .in12(msg_out12), .in13(msg_out13), .in14(msg_out14), .in15(msg_out15));

  data_interface #(.DATA_WIDTH(64)) data_in0();
  data_interface #(.DATA_WIDTH(64)) data_in1();
  data_interface #(.DATA_WIDTH(64)) data_in2();
  data_interface #(.DATA_WIDTH(64)) data_in3();
  data_interface #(.DATA_WIDTH(64)) data_in4();
  data_interface #(.DATA_WIDTH(64)) data_in5();
  data_interface #(.DATA_WIDTH(64)) data_in6();
  data_interface #(.DATA_WIDTH(64)) data_in7();
  data_interface #(.DATA_WIDTH(64)) data_in8();
  data_interface #(.DATA_WIDTH(64)) data_in9();
  data_interface #(.DATA_WIDTH(64)) data_in10();
  data_interface #(.DATA_WIDTH(64)) data_in11();
  data_interface #(.DATA_WIDTH(64)) data_in12();
  data_interface #(.DATA_WIDTH(64)) data_in13();
  data_interface #(.DATA_WIDTH(64)) data_out0();
  data_interface #(.DATA_WIDTH(64)) data_out1();
  data_interface #(.DATA_WIDTH(64)) data_out2();
  data_interface #(.DATA_WIDTH(64)) data_out3();
  data_interface #(.DATA_WIDTH(64)) data_out4();
  data_interface #(.DATA_WIDTH(64)) data_out5();
  data_interface #(.DATA_WIDTH(64)) data_out6();
  data_interface #(.DATA_WIDTH(64)) data_out7();

buffer_input_staged_ripple_5 input_buffer_0 (
    .clock(clock),
    .cu(mib_to_in0),
    .dtn(msg_in0),
    .pu(data_in0)
);
buffer_input_staged_ripple_5 input_buffer_1 (
    .clock(clock),
    .cu(mib_to_in1),
    .dtn(msg_in1),
    .pu(data_in1)
);
buffer_input_staged_ripple_5 input_buffer_2 (
    .clock(clock),
    .cu(mib_to_in2),
    .dtn(msg_in2),
    .pu(data_in2)
);
buffer_input_staged_ripple_5 input_buffer_3 (
    .clock(clock),
    .cu(mib_to_in3),
    .dtn(msg_in3),
    .pu(data_in3)
);
buffer_input_staged_ripple_5 input_buffer_4 (
    .clock(clock),
    .cu(mib_to_in4),
    .dtn(msg_in4),
    .pu(data_in4)
);
buffer_input_staged_ripple_5 input_buffer_5 (
    .clock(clock),
    .cu(mib_to_in5),
    .dtn(msg_in5),
    .pu(data_in5)
);
buffer_input_staged_ripple_5 input_buffer_6 (
    .clock(clock),
    .cu(mib_to_in6),
    .dtn(msg_in6),
    .pu(data_in6)
);
buffer_input_staged_ripple_5 input_buffer_7 (
    .clock(clock),
    .cu(mib_to_in7),
    .dtn(msg_in7),
    .pu(data_in7)
);
buffer_input_staged_ripple_5 input_buffer_8 (
    .clock(clock),
    .cu(mib_to_in8),
    .dtn(msg_in8),
    .pu(data_in8)
);
buffer_input_staged_ripple_5 input_buffer_9 (
    .clock(clock),
    .cu(mib_to_in9),
    .dtn(msg_in9),
    .pu(data_in9)
);
buffer_input_staged_ripple_5 input_buffer_10 (
    .clock(clock),
    .cu(mib_to_in10),
    .dtn(msg_in10),
    .pu(data_in10)
);
buffer_input_staged_ripple_5 input_buffer_11 (
    .clock(clock),
    .cu(mib_to_in11),
    .dtn(msg_in11),
    .pu(data_in11)
);
buffer_input_staged_ripple_5 input_buffer_12 (
    .clock(clock),
    .cu(mib_to_in12),
    .dtn(msg_in12),
    .pu(data_in12)
);
buffer_input_staged_ripple_5 input_buffer_13 (
    .clock(clock),
    .cu(mib_to_in13),
    .dtn(msg_in13),
    .pu(data_in13)
);
buffer_output #(.ADDR_WIDTH(4),
.DATA_WIDTH(64),
.DEPTH(5),
.FROM_ADDR(0)) output_buffer_0 (
    .clock(clock),
    .cu(mib_to_out0),
    .data(data_out0),
    .dtn(msg_out0)
);
buffer_output #(.ADDR_WIDTH(4),
.DATA_WIDTH(64),
.DEPTH(5),
.FROM_ADDR(1)) output_buffer_1 (
    .clock(clock),
    .cu(mib_to_out1),
    .data(data_out1),
    .dtn(msg_out1)
);
buffer_output #(.ADDR_WIDTH(4),
.DATA_WIDTH(64),
.DEPTH(5),
.FROM_ADDR(2)) output_buffer_2 (
    .clock(clock),
    .cu(mib_to_out2),
    .data(data_out2),
    .dtn(msg_out2)
);
buffer_output #(.ADDR_WIDTH(4),
.DATA_WIDTH(64),
.DEPTH(5),
.FROM_ADDR(3)) output_buffer_3 (
    .clock(clock),
    .cu(mib_to_out3),
    .data(data_out3),
    .dtn(msg_out3)
);
buffer_output #(.ADDR_WIDTH(4),
.DATA_WIDTH(64),
.DEPTH(5),
.FROM_ADDR(4)) output_buffer_4 (
    .clock(clock),
    .cu(mib_to_out4),
    .data(data_out4),
    .dtn(msg_out4)
);
buffer_output #(.ADDR_WIDTH(4),
.DATA_WIDTH(64),
.DEPTH(5),
.FROM_ADDR(5)) output_buffer_5 (
    .clock(clock),
    .cu(mib_to_out5),
    .data(data_out5),
    .dtn(msg_out5)
);
buffer_output #(.ADDR_WIDTH(4),
.DATA_WIDTH(64),
.DEPTH(5),
.FROM_ADDR(6)) output_buffer_6 (
    .clock(clock),
    .cu(mib_to_out6),
    .data(data_out6),
    .dtn(msg_out6)
);
buffer_output #(.ADDR_WIDTH(4),
.DATA_WIDTH(64),
.DEPTH(5),
.FROM_ADDR(7)) output_buffer_7 (
    .clock(clock),
    .cu(mib_to_out7),
    .data(data_out7),
    .dtn(msg_out7)
);
mem_interface #(.MEMADDR_WIDTH(64),.DATA_WIDTH(64)) cached_progmem();
cache_readonly_dm #(.DATA_WIDTH(64),.ADDR_WIDTH(64),.LINE_WIDTH(256),.LINE_COUNT(128)) progmem_impl(.clock(clock),.cpu(cached_progmem),.axi(mem_progmem));
cu_simple #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) cu(.clock(clock), .start(start), .done(done), .idle(idle), .instr_mem(cached_progmem), .branch_condition(data_in0), .to_mib(cu_to_mib));
lsu_axi #(.DATA_WIDTH(64)) unit1(.clock(clock),.axi(mem_gmem),.op(data_in1),.address(data_in2),.value(data_in3),.result(data_out0));
  rob #(.DATA_WIDTH(64),.DEPTH(5)) unit2(.clock(clock),.in(data_in4),.out(data_out1));
alu_pipelined_toomcook #(.DATA_WIDTH(64)) unit3(.clock(clock),.operator(data_in5),.left(data_in6),.right(data_in7),.result(data_out2),.overflow(data_out3));
alu_pipelined_toomcook #(.DATA_WIDTH(64)) unit4(.clock(clock),.operator(data_in8),.left(data_in9),.right(data_in10),.result(data_out4),.overflow(data_out5));
alu_pipelined_toomcook #(.DATA_WIDTH(64)) unit5(.clock(clock),.operator(data_in11),.left(data_in12),.right(data_in13),.result(data_out6),.overflow(data_out7));
endmodule
