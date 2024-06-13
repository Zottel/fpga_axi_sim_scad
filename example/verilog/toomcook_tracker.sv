`default_nettype none

module toomcook_tracker
#(parameter STAGE=8
) 
(
	input wire clk,
	input wire rst,
	input wire new_data,
	output wire ack_data,
	input wire release_data,
	output reg [STAGE-1:0] valid_register,
	output wire [STAGE-1:0] enable_register
);

localparam high_val = 1'b1;
localparam low_val = 1'b0;

wire [STAGE-1:0] register_next;
wire full;

assign full= &valid_register;

//assign ack_data = (full==1'b0)?new_data:1'b0;
assign ack_data = (release_data || ~full) && new_data;


always @(posedge clk or posedge rst)
begin
  if(rst==1'b1)
  begin
    valid_register <= {STAGE{low_val}};
  end
  else
  begin
    valid_register <= register_next;
  end
end

genvar i;
generate
for(i=0;i<STAGE;i=i+1)begin
  assign enable_register[i]= (~&valid_register[i:0])||release_data;
end
for(i=0;i<STAGE-1;i=i+1)begin
  assign register_next[i]=(enable_register[i]==1'b1)?valid_register[i+1]:valid_register[i];
end
assign register_next[STAGE-1]=(enable_register[STAGE-1]==1'b1)?new_data:valid_register[STAGE-1];
endgenerate

endmodule

