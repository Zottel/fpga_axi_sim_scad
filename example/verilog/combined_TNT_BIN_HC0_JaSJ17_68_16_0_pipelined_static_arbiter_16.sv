`default_nettype none

module combined_TNT_BIN_HC0_JaSJ17_68_16_0_pipelined_static_arbiter_16 (input wire clock, message_interface_nonblocking.producer out0, message_interface_nonblocking.producer out1, message_interface_nonblocking.producer out2, message_interface_nonblocking.producer out3, message_interface_nonblocking.producer out4, message_interface_nonblocking.producer out5, message_interface_nonblocking.producer out6, message_interface_nonblocking.producer out7, message_interface_nonblocking.producer out8, message_interface_nonblocking.producer out9, message_interface_nonblocking.producer out10, message_interface_nonblocking.producer out11, message_interface_nonblocking.producer out12, message_interface_nonblocking.producer out13, message_interface_nonblocking.producer out14, message_interface_nonblocking.producer out15, message_interface.consumer in0, message_interface.consumer in1, message_interface.consumer in2, message_interface.consumer in3, message_interface.consumer in4, message_interface.consumer in5, message_interface.consumer in6, message_interface.consumer in7, message_interface.consumer in8, message_interface.consumer in9, message_interface.consumer in10, message_interface.consumer in11, message_interface.consumer in12, message_interface.consumer in13, message_interface.consumer in14, message_interface.consumer in15);
message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) inner0();
message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) inner1();
message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) inner2();
message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) inner3();
message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) inner4();
message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) inner5();
message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) inner6();
message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) inner7();
message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) inner8();
message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) inner9();
message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) inner10();
message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) inner11();
message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) inner12();
message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) inner13();
message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) inner14();
message_interface_nonblocking #(.ADDR_WIDTH(4),.DATA_WIDTH(64)) inner15();
static_arbiter_16 arbiter(.clock(clock), .out0(inner0), .out1(inner1), .out2(inner2), .out3(inner3), .out4(inner4), .out5(inner5), .out6(inner6), .out7(inner7), .out8(inner8), .out9(inner9), .out10(inner10), .out11(inner11), .out12(inner12), .out13(inner13), .out14(inner14), .out15(inner15), .in0(in0), .in1(in1), .in2(in2), .in3(in3), .in4(in4), .in5(in5), .in6(in6), .in7(in7), .in8(in8), .in9(in9), .in10(in10), .in11(in11), .in12(in12), .in13(in13), .in14(in14), .in15(in15));
TNT_BIN_HC0_JaSJ17_68_16_0_pipelined inner_dtn(.clock(clock), .out0(out0), .out1(out1), .out2(out2), .out3(out3), .out4(out4), .out5(out5), .out6(out6), .out7(out7), .out8(out8), .out9(out9), .out10(out10), .out11(out11), .out12(out12), .out13(out13), .out14(out14), .out15(out15), .in0(inner0), .in1(inner1), .in2(inner2), .in3(inner3), .in4(inner4), .in5(inner5), .in6(inner6), .in7(inner7), .in8(inner8), .in9(inner9), .in10(inner10), .in11(inner11), .in12(inner12), .in13(inner13), .in14(inner14), .in15(inner15));
endmodule
