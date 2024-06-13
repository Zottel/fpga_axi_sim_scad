`default_nettype none

module toomcook #(
	parameter WIDTH = 32
) (
	input  wire clk,
	input  wire rst,
	input  wire new_data,
	output wire ack_data,

	input  wire release_data,
	output wire valid_output,

	input  wire [WIDTH -1:0]  a_in,
	input  wire [WIDTH -1:0]  b_in,
	output wire [WIDTH*2 -1:0]  result
);

localparam high_val = 1'b1;
localparam low_val = 1'b0;

//Stage 1
localparam WIDTH_STAGE1=WIDTH;
reg [WIDTH_STAGE1-1:0] x,y;
wire [WIDTH_STAGE1-1:0] x_next,y_next;
wire [WIDTH -1:0] abs_a_in,abs_b_in;
reg sign;
wire sign_next;
//Stage 2
localparam WIDTH_STAGE2=WIDTH;
localparam WIDTH_SUBTERM_STAGE2=WIDTH/2;
reg [WIDTH_STAGE2-1:0] a,h1l2,h2l1,c;
reg [WIDTH_STAGE2-1:0] a_next,h1l2_next,h2l1_next,c_next;
wire unsigned [WIDTH_SUBTERM_STAGE2-1:0] H1,H2,L1,L2;
reg sign2;
//Stage 3
localparam WIDTH_a_sum_c_STAGE3=WIDTH*2;
localparam WIDTH_b_STAGE3=WIDTH+1;
localparam FILL_A_LOW=WIDTH;
localparam FILL_C_HIGH=WIDTH;
reg [WIDTH_a_sum_c_STAGE3-1:0] a_sum_c;
reg [WIDTH_b_STAGE3-1:0] b;
wire [WIDTH_a_sum_c_STAGE3-1:0] a_sum_c_next;
wire [WIDTH_b_STAGE3-1:0] b_next;
reg sign3;
//Stage 4
localparam RESULT_WIDTH_STAGE4=WIDTH*2;
localparam FILL_B_LOW=WIDTH/2;
localparam FILL_B_HIGH=RESULT_WIDTH_STAGE4-WIDTH_b_STAGE3-FILL_B_LOW;
reg [RESULT_WIDTH_STAGE4-1:0] result_reg;
wire [RESULT_WIDTH_STAGE4-1:0] result_next;
wire [RESULT_WIDTH_STAGE4-1:0] result_temp;


//Signals for the tracker
localparam TRACKER_STAGE=4;
wire [TRACKER_STAGE-1:0] valid_register;
wire [TRACKER_STAGE-1:0] enable_register;
//////////////////////////////////////////////////////////////////////
/////////////// Tracker ////////////////////////////////////////////// 
//////////////////////////////////////////////////////////////////////
toomcook_tracker #(.STAGE(TRACKER_STAGE)) stage_tracker
(
 .clk(clk),
 .rst(rst),
 .new_data(new_data),
 .ack_data(ack_data),
 .release_data(release_data),
 .valid_register(valid_register),
 .enable_register(enable_register)
);
assign valid_output = valid_register[0];
///////////////////////////////////////////////////////
//Stage 1
always @(posedge clk or posedge rst) 
begin
  if(rst==1'b1)
  begin
     x <= {WIDTH_STAGE1{low_val}}; 
     y <= {WIDTH_STAGE1{low_val}}; 
     sign<={low_val};
  end
  else
  begin 
     if (enable_register[3]==1'b1)
     begin
     x <= x_next; 
     y <= y_next;
     sign<=sign_next;
     end
  end
end

assign abs_a_in=(a_in[WIDTH-1]==1'b1)? ((~a_in)+1):a_in;
assign abs_b_in=(b_in[WIDTH-1]==1'b1)? ((~b_in)+1):b_in;
assign sign_next=(a_in[WIDTH-1]==b_in[WIDTH-1])?1'b0:1'b1;

assign x_next = {abs_a_in};
assign y_next = {abs_b_in};

///////////////////////////////////////////////////////
//Stage 2
always @(posedge clk or posedge rst) 
begin
  if(rst==1'b1)
  begin
     a <= {WIDTH_STAGE2{low_val}}; 
     h1l2 <= {WIDTH_STAGE2{low_val}}; 
     h2l1 <= {WIDTH_STAGE2{low_val}}; 
     c <= {WIDTH_STAGE2{low_val}}; 
     sign2<={low_val};
  end
  else
  begin 
     if (enable_register[2]==1'b1)
     begin
     a <= a_next; 
     h1l2 <= h1l2_next; 
     h2l1 <= h2l1_next; 
     c <= c_next;
     sign2<=sign; 
     end
  end
end

assign H1={x[WIDTH_STAGE1-1:WIDTH/2]};
assign L1={x[WIDTH/2-1:0]};
assign H2={y[WIDTH_STAGE1-1:WIDTH/2]};
assign L2={y[WIDTH/2-1:0]};

assign a_next=H1*H2;
assign c_next=L1*L2;
assign h1l2_next=H1*L2;
assign h2l1_next=H2*L1;

///////////////////////////////////////////////////////
//Stage 3
always @(posedge clk or posedge rst) 
begin
  if(rst==1'b1)
  begin
     a_sum_c <= {WIDTH_a_sum_c_STAGE3{low_val}}; 
     b <= {WIDTH_b_STAGE3{low_val}}; 
     sign3<={low_val};
  end
  else
  begin 
     if (enable_register[1]==1'b1)
     begin
     a_sum_c <= a_sum_c_next; 
     b <= b_next; 
     sign3<=sign2;
     end
  end
end

assign a_sum_c_next={a,c};
assign b_next={{1'b0},h2l1}+{{1'b0},h1l2};

///////////////////////////////////////////////////////
//Stage 4
always @(posedge clk or posedge rst) 
begin
  if(rst==1'b1)
  begin
     result_reg <= {RESULT_WIDTH_STAGE4{low_val}}; 
  end
  else
  begin 
     if (enable_register[0]==1'b1)
     begin
     result_reg <= result_next; 
     end
  end
end

assign result_temp=a_sum_c+{{FILL_B_HIGH{low_val}},b,{FILL_B_LOW{low_val}}};
assign result_next = (sign3==1'b1)?((~result_temp)+1):result_temp;

assign result=result_reg;

endmodule

