`default_nettype none

module alu_pipelined_mult_toomcook
	#(parameter DATA_WIDTH=32,
		OPCODE_WIDTH = 6,
		ALU_OP_MUL  = 6'd16,
		FIFO_LENGTH = 4 //This signal goes from 1 to 4
		) (
		input wire clock,
		data_interface.consumer operator,
		data_interface.consumer left,
		data_interface.consumer right,
		data_interface.producer result,
		data_interface.producer overflow);

wire new_data;
wire ack_data;
wire release_data;
wire valid_output;
wire right_operation;

wire [DATA_WIDTH-1:0] a_in,b_in;
wire [DATA_WIDTH*2-1:0] result_temp;
localparam high_val = 1'b1;
localparam low_val = 1'b0;

assign right_operation=(operator.data[OPCODE_WIDTH-1:0]==ALU_OP_MUL)?1'b1:1'b0;
assign new_data= operator.valid && left.valid && right.valid && right_operation;
assign operator.ack=ack_data;
assign left.ack=ack_data;
assign right.ack=ack_data;
assign release_data= result.ack && overflow.ack;
assign result.valid=valid_output;
assign overflow.valid=valid_output;

toomcook #(.WIDTH(DATA_WIDTH)) multiplier
(
 .clk(clock),
 .rst(1'b0),
 .new_data(new_data),
 .ack_data(ack_data),
 .release_data(release_data),
 .valid_output(valid_output),
 .a_in(a_in),
 .b_in(b_in),
 .result(result_temp)
);
assign result.data=result_temp[DATA_WIDTH-1:0];
assign overflow.data=result_temp[DATA_WIDTH*2-1:DATA_WIDTH];
assign a_in=(ack_data==1'b1)?left.data:{DATA_WIDTH{low_val}};
assign b_in=(ack_data==1'b1)?right.data:{DATA_WIDTH{low_val}};



endmodule


