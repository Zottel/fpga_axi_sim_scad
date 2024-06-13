`default_nettype none

module buffer_input_staged_ripple_5(
   input wire clock,
   message_interface_nonblocking.consumer dtn,
   instruction_input_interface.consumer cu,
   data_interface.producer pu
);
buffer_line_interface #(.ADDR_WIDTH(4), .DATA_WIDTH(64)) line_before0();
buffer_line_interface #(.ADDR_WIDTH(4), .DATA_WIDTH(64)) line_before1();
message_interface_nonblocking #(.ADDR_WIDTH(4), .DATA_WIDTH(64)) dtn_after0();
instruction_input_interface #(.ADDR_WIDTH(4), .DATA_WIDTH(64)) cu_after0();
buffer_input_stage_ripple #(.ADDR_WIDTH(4), .DATA_WIDTH(64)) stage0 (
  .clock(clock),
  .dtn(dtn), .dtn_forward(dtn_after0),
  .cu(cu), .cu_forward(cu_after0),
  .line_out(line_before0), .line_in(line_before1));
buffer_line_interface #(.ADDR_WIDTH(4), .DATA_WIDTH(64)) line_before2();
message_interface_nonblocking #(.ADDR_WIDTH(4), .DATA_WIDTH(64)) dtn_after1();
instruction_input_interface #(.ADDR_WIDTH(4), .DATA_WIDTH(64)) cu_after1();
buffer_input_stage_ripple #(.ADDR_WIDTH(4), .DATA_WIDTH(64)) stage1 (
  .clock(clock),
  .dtn(dtn_after0), .dtn_forward(dtn_after1),
  .cu(cu_after0), .cu_forward(cu_after1),
  .line_out(line_before1), .line_in(line_before2));
buffer_line_interface #(.ADDR_WIDTH(4), .DATA_WIDTH(64)) line_before3();
message_interface_nonblocking #(.ADDR_WIDTH(4), .DATA_WIDTH(64)) dtn_after2();
instruction_input_interface #(.ADDR_WIDTH(4), .DATA_WIDTH(64)) cu_after2();
buffer_input_stage_ripple #(.ADDR_WIDTH(4), .DATA_WIDTH(64)) stage2 (
  .clock(clock),
  .dtn(dtn_after1), .dtn_forward(dtn_after2),
  .cu(cu_after1), .cu_forward(cu_after2),
  .line_out(line_before2), .line_in(line_before3));
buffer_line_interface #(.ADDR_WIDTH(4), .DATA_WIDTH(64)) line_before4();
message_interface_nonblocking #(.ADDR_WIDTH(4), .DATA_WIDTH(64)) dtn_after3();
instruction_input_interface #(.ADDR_WIDTH(4), .DATA_WIDTH(64)) cu_after3();
buffer_input_stage_ripple #(.ADDR_WIDTH(4), .DATA_WIDTH(64)) stage3 (
  .clock(clock),
  .dtn(dtn_after2), .dtn_forward(dtn_after3),
  .cu(cu_after2), .cu_forward(cu_after3),
  .line_out(line_before3), .line_in(line_before4));
buffer_line_interface #(.ADDR_WIDTH(4), .DATA_WIDTH(64)) line_before5();
message_interface_nonblocking #(.ADDR_WIDTH(4), .DATA_WIDTH(64)) dtn_after4();
instruction_input_interface #(.ADDR_WIDTH(4), .DATA_WIDTH(64)) cu_after4();
buffer_input_stage_ripple #(.ADDR_WIDTH(4), .DATA_WIDTH(64)) stage4 (
  .clock(clock),
  .dtn(dtn_after3), .dtn_forward(dtn_after4),
  .cu(cu_after3), .cu_forward(cu_after4),
  .line_out(line_before4), .line_in(line_before5));
// Proper termination for last stage.
assign cu_after4.move_ack = 0;
assign cu_after4.immediate_ack = 0;
assign line_before5.addr_valid = 0;
assign line_before5.data_valid = 0;
// Connect PU to first line interface.
assign pu.data = line_before0.data;
assign pu.valid = line_before0.data_valid;
assign line_before0.ack = pu.ack & line_before0.data_valid;
`ifdef FORMAL
// ----------------------------------------------------------------------
// Proof preconditions
// ----------------------------------------------------------------------

// Workaround to enforce all irrelevant address bits being 0.
// This is needed because we can't enforce interface parameters in module
// ports.
assume property (dtn.from[4-1:0] == dtn.from);

// ----------------------------------------------------------------------
// Tags FIFO
// ----------------------------------------------------------------------
reg [4-1:0] tag_fifo [5+1:0];
reg [$clog2(5)+2:0] tag_count = 0;

assert property (tag_count <= (5));
cover property (tag_count == 3);

wire buffer_is_shifting = line_before0.data_valid && line_before0.ack;
wire new_tag = cu.move_valid && cu.move_ack;
wire [$clog2(5)+1:0] next_tag_count = tag_count + (new_tag?1:0) - (buffer_is_shifting?1:0);
cover property (next_tag_count == 5);

always @ (posedge clock) begin
    // Do not care about immediates for now.
    assume property (!cu.immediate_valid);
    
    // Ensure it is possible for the buffer to stall the CU.
    // Is the buffer ever shifted?
    cover_buffer_shifting:
        cover (buffer_is_shifting);
    
    tag_count <= next_tag_count;
    // TODO: make tag_count match addr.valid expectations
    
    if (buffer_is_shifting && new_tag) begin
        if (tag_count > (0+1)) begin
            tag_fifo[0] <= tag_fifo[0+1];
        end else if (tag_count == (0+1)) begin
            if (new_tag) begin
                tag_fifo[0] <= cu.move_from;
            end
        end
    end else if (buffer_is_shifting ) begin
        if (tag_count > (0+1)) begin
            tag_fifo[0] <= tag_fifo[0+1];
        end
    end else if (new_tag) begin
        if (tag_count == 0) begin
            tag_fifo[0] <= cu.move_from;
        end
    end
    
    line_addr_valid_matching_tag_count_0:
        assert (tag_count <= 0 || line_before0.addr_valid);
    line_addr_matching_tagfifo_0:
        assert (tag_count <= 0 || (line_before0.addr == tag_fifo[0]));
    // TODO: make tag_count match addr.valid expectations
    
    if (buffer_is_shifting && new_tag) begin
        if (tag_count > (1+1)) begin
            tag_fifo[1] <= tag_fifo[1+1];
        end else if (tag_count == (1+1)) begin
            if (new_tag) begin
                tag_fifo[1] <= cu.move_from;
            end
        end
    end else if (buffer_is_shifting ) begin
        if (tag_count > (1+1)) begin
            tag_fifo[1] <= tag_fifo[1+1];
        end
    end else if (new_tag) begin
        if (tag_count == 1) begin
            tag_fifo[1] <= cu.move_from;
        end
    end
    
    line_addr_valid_matching_tag_count_1:
        assert (tag_count <= 1 || line_before1.addr_valid);
    line_addr_matching_tagfifo_1:
        assert (tag_count <= 1 || (line_before1.addr == tag_fifo[1]));
    // TODO: make tag_count match addr.valid expectations
    
    if (buffer_is_shifting && new_tag) begin
        if (tag_count > (2+1)) begin
            tag_fifo[2] <= tag_fifo[2+1];
        end else if (tag_count == (2+1)) begin
            if (new_tag) begin
                tag_fifo[2] <= cu.move_from;
            end
        end
    end else if (buffer_is_shifting ) begin
        if (tag_count > (2+1)) begin
            tag_fifo[2] <= tag_fifo[2+1];
        end
    end else if (new_tag) begin
        if (tag_count == 2) begin
            tag_fifo[2] <= cu.move_from;
        end
    end
    
    line_addr_valid_matching_tag_count_2:
        assert (tag_count <= 2 || line_before2.addr_valid);
    line_addr_matching_tagfifo_2:
        assert (tag_count <= 2 || (line_before2.addr == tag_fifo[2]));
    // TODO: make tag_count match addr.valid expectations
    
    if (buffer_is_shifting && new_tag) begin
        if (tag_count > (3+1)) begin
            tag_fifo[3] <= tag_fifo[3+1];
        end else if (tag_count == (3+1)) begin
            if (new_tag) begin
                tag_fifo[3] <= cu.move_from;
            end
        end
    end else if (buffer_is_shifting ) begin
        if (tag_count > (3+1)) begin
            tag_fifo[3] <= tag_fifo[3+1];
        end
    end else if (new_tag) begin
        if (tag_count == 3) begin
            tag_fifo[3] <= cu.move_from;
        end
    end
    
    line_addr_valid_matching_tag_count_3:
        assert (tag_count <= 3 || line_before3.addr_valid);
    line_addr_matching_tagfifo_3:
        assert (tag_count <= 3 || (line_before3.addr == tag_fifo[3]));
    // TODO: make tag_count match addr.valid expectations
    
    if (buffer_is_shifting && new_tag) begin
        if (tag_count > (4+1)) begin
        end else if (tag_count == (4+1)) begin
            if (new_tag) begin
                tag_fifo[4] <= cu.move_from;
            end
        end
    end else if (buffer_is_shifting ) begin
        if (tag_count > (4+1)) begin
        end
    end else if (new_tag) begin
        if (tag_count == 4) begin
            tag_fifo[4] <= cu.move_from;
        end
    end
    
    line_addr_valid_matching_tag_count_4:
        assert (tag_count <= 4 || line_before4.addr_valid);
    line_addr_matching_tagfifo_4:
        assert (tag_count <= 4 || (line_before4.addr == tag_fifo[4]));
    // TODO: make tag_count match addr.valid expectations
    
    if (buffer_is_shifting && new_tag) begin
        if (tag_count > (5+1)) begin
        end else if (tag_count == (5+1)) begin
            if (new_tag) begin
                tag_fifo[5] <= cu.move_from;
            end
        end
    end else if (buffer_is_shifting ) begin
        if (tag_count > (5+1)) begin
        end
    end else if (new_tag) begin
        if (tag_count == 5) begin
            tag_fifo[5] <= cu.move_from;
        end
    end
    
    line_addr_valid_matching_tag_count_5:
        assert (tag_count <= 5 || line_before5.addr_valid);
    line_addr_matching_tagfifo_5:
        assert (tag_count <= 5 || (line_before5.addr == tag_fifo[5]));
end
// ----------------------------------------------------------------------
// Arbitrary But Fixed Tag
// ----------------------------------------------------------------------

(* anyconst *) reg [4-1:0] fixed_A;

// ----------------------------------------------------------------------
// Counting Tags
// ----------------------------------------------------------------------
wire [$clog2(5)+1:0] Amax [5+1];

assign Amax[0] = ((tag_count > 0 && tag_fifo[0] == fixed_A) ? 1 : 0);
assert property (Amax[0] <= (0+1));
assign Amax[1] = Amax[1-1] + ((tag_count > 1 && tag_fifo[1] == fixed_A) ? 1 : 0);
assert property (Amax[1] <= (1+1));
assign Amax[2] = Amax[2-1] + ((tag_count > 2 && tag_fifo[2] == fixed_A) ? 1 : 0);
assert property (Amax[2] <= (2+1));
assign Amax[3] = Amax[3-1] + ((tag_count > 3 && tag_fifo[3] == fixed_A) ? 1 : 0);
assert property (Amax[3] <= (3+1));
assign Amax[4] = Amax[4-1] + ((tag_count > 4 && tag_fifo[4] == fixed_A) ? 1 : 0);
assert property (Amax[4] <= (4+1));
assign Amax[5] = Amax[5-1] + ((tag_count > 5 && tag_fifo[5] == fixed_A) ? 1 : 0);
assert property (Amax[5] <= (5+1));

wire [$clog2(5)+1:0] Acnt [5+1];

assign Acnt[0] = ((line_before0.addr_valid && line_before0.addr == fixed_A && line_before0.data_valid && !line_before0.data_just_matched) ? 1 : 0);
assert property (Acnt[0] <= Amax[0]);
assign Acnt[1] = Acnt[1-1] + ((line_before1.addr_valid && line_before1.addr == fixed_A && line_before1.data_valid && !line_before1.data_just_matched) ? 1 : 0);
assert property (Acnt[1] <= Amax[1]);
assign Acnt[2] = Acnt[2-1] + ((line_before2.addr_valid && line_before2.addr == fixed_A && line_before2.data_valid && !line_before2.data_just_matched) ? 1 : 0);
assert property (Acnt[2] <= Amax[2]);
assign Acnt[3] = Acnt[3-1] + ((line_before3.addr_valid && line_before3.addr == fixed_A && line_before3.data_valid && !line_before3.data_just_matched) ? 1 : 0);
assert property (Acnt[3] <= Amax[3]);
assign Acnt[4] = Acnt[4-1] + ((line_before4.addr_valid && line_before4.addr == fixed_A && line_before4.data_valid && !line_before4.data_just_matched) ? 1 : 0);
assert property (Acnt[4] <= Amax[4]);
assign Acnt[5] = Acnt[5-1] + ((line_before5.addr_valid && line_before5.addr == fixed_A && line_before5.data_valid && !line_before5.data_just_matched) ? 1 : 0);
assert property (Acnt[5] <= Amax[5]);

wire [$clog2(5)+1:0] Acntripple [5+1];

assign Acntripple[0] = Acntripple[0+1] + ((dtn.valid && dtn.from[4-1:0] == fixed_A) ? 1 : 0);
assert property (Acntripple[0] <= Amax[5]);
assign Acntripple[1] = Acntripple[1+1] + ((dtn_after0.valid && dtn_after0.from == fixed_A) ? 1 : 0);
assert property (Acntripple[1] <= Amax[5]);
assign Acntripple[2] = Acntripple[2+1] + ((dtn_after1.valid && dtn_after1.from == fixed_A) ? 1 : 0);
assert property (Acntripple[2] <= Amax[5]);
assign Acntripple[3] = Acntripple[3+1] + ((dtn_after2.valid && dtn_after2.from == fixed_A) ? 1 : 0);
assert property (Acntripple[3] <= Amax[5]);
assign Acntripple[4] = Acntripple[4+1] + ((dtn_after3.valid && dtn_after3.from == fixed_A) ? 1 : 0);
assert property (Acntripple[4] <= Amax[5]);
assign Acntripple[5] = Acnt[5] + ((dtn_after4.valid && dtn_after4.from == fixed_A) ? 1 : 0);
assert property (Acntripple[5] <= Amax[5]);

no_more_values_than_space_available_0:
  assert property ((Acntripple[0] - Acnt[0]) <= (Amax[5]-Amax[0]));
no_more_values_than_space_available_1:
  assert property ((Acntripple[1] - Acnt[1]) <= (Amax[5]-Amax[1]));
no_more_values_than_space_available_2:
  assert property ((Acntripple[2] - Acnt[2]) <= (Amax[5]-Amax[2]));
no_more_values_than_space_available_3:
  assert property ((Acntripple[3] - Acnt[3]) <= (Amax[5]-Amax[3]));
no_more_values_than_space_available_4:
  assert property ((Acntripple[4] - Acnt[4]) <= (Amax[5]-Amax[4]));
no_more_values_than_space_available_5:
  assert property ((Acntripple[5] - Acnt[5]) <= (Amax[5]-Amax[5]));

no_more_ripple_messages_than_space_available_0:
  assert property ((Acntripple[0] - Acnt[5]) <= (Amax[5]-Amax[0]));
no_more_ripple_messages_than_space_available_1:
  assert property ((Acntripple[1] - Acnt[5]) <= (Amax[5]-Amax[1]));
no_more_ripple_messages_than_space_available_2:
  assert property ((Acntripple[2] - Acnt[5]) <= (Amax[5]-Amax[2]));
no_more_ripple_messages_than_space_available_3:
  assert property ((Acntripple[3] - Acnt[5]) <= (Amax[5]-Amax[3]));
no_more_ripple_messages_than_space_available_4:
  assert property ((Acntripple[4] - Acnt[5]) <= (Amax[5]-Amax[4]));
no_more_ripple_messages_than_space_available_5:
  assert property ((Acntripple[5] - Acnt[5]) <= (Amax[5]-Amax[5]));

no_more_messages_than_tags:
  assume property (!dtn.valid || dtn.from[4-1:0] != fixed_A || Acntripple[0] < Amax[5]);
// ----------------------------------------------------------------------
// Messages from A FIFO
// ----------------------------------------------------------------------
reg [64-1:0] value_fifo [5+1:0];
reg [$clog2(5)+1:0] value_count = 0;

// Should be ensured by
no_more_values_than_tags:
  assert property (value_count <= tag_count);

wire value_buffer_is_shifting = buffer_is_shifting && tag_fifo[0] == fixed_A;
wire new_value = dtn.valid && (dtn.from == fixed_A);
wire [$clog2(5)+1:0] next_value_count = value_count + (new_value?1:0) - (value_buffer_is_shifting?1:0);

always @ (posedge clock) begin
    value_count <= next_value_count;
    
    if (value_buffer_is_shifting && new_value) begin
        if (value_count > (0+1)) begin
            value_fifo[0] <= value_fifo[0+1];
        end else if (value_count == (0+1)) begin
            if (new_value) begin
                value_fifo[0] <= dtn.data;
            end
        end
    end else if (value_buffer_is_shifting ) begin
        if (value_count > (0+1)) begin
            value_fifo[0] <= value_fifo[0+1];
        end
    end else if (new_value) begin
        if (value_count == 0) begin
            value_fifo[0] <= dtn.data;
        end
    end
    if (value_buffer_is_shifting && new_value) begin
        if (value_count > (1+1)) begin
            value_fifo[1] <= value_fifo[1+1];
        end else if (value_count == (1+1)) begin
            if (new_value) begin
                value_fifo[1] <= dtn.data;
            end
        end
    end else if (value_buffer_is_shifting ) begin
        if (value_count > (1+1)) begin
            value_fifo[1] <= value_fifo[1+1];
        end
    end else if (new_value) begin
        if (value_count == 1) begin
            value_fifo[1] <= dtn.data;
        end
    end
    if (value_buffer_is_shifting && new_value) begin
        if (value_count > (2+1)) begin
            value_fifo[2] <= value_fifo[2+1];
        end else if (value_count == (2+1)) begin
            if (new_value) begin
                value_fifo[2] <= dtn.data;
            end
        end
    end else if (value_buffer_is_shifting ) begin
        if (value_count > (2+1)) begin
            value_fifo[2] <= value_fifo[2+1];
        end
    end else if (new_value) begin
        if (value_count == 2) begin
            value_fifo[2] <= dtn.data;
        end
    end
    if (value_buffer_is_shifting && new_value) begin
        if (value_count > (3+1)) begin
            value_fifo[3] <= value_fifo[3+1];
        end else if (value_count == (3+1)) begin
            if (new_value) begin
                value_fifo[3] <= dtn.data;
            end
        end
    end else if (value_buffer_is_shifting ) begin
        if (value_count > (3+1)) begin
            value_fifo[3] <= value_fifo[3+1];
        end
    end else if (new_value) begin
        if (value_count == 3) begin
            value_fifo[3] <= dtn.data;
        end
    end
    if (value_buffer_is_shifting && new_value) begin
        if (value_count > (4+1)) begin
        end else if (value_count == (4+1)) begin
            if (new_value) begin
                value_fifo[4] <= dtn.data;
            end
        end
    end else if (value_buffer_is_shifting ) begin
        if (value_count > (4+1)) begin
        end
    end else if (new_value) begin
        if (value_count == 4) begin
            value_fifo[4] <= dtn.data;
        end
    end
    if (value_buffer_is_shifting && new_value) begin
        if (value_count > (5+1)) begin
        end else if (value_count == (5+1)) begin
            if (new_value) begin
                value_fifo[5] <= dtn.data;
            end
        end
    end else if (value_buffer_is_shifting ) begin
        if (value_count > (5+1)) begin
        end
    end else if (new_value) begin
        if (value_count == 5) begin
            value_fifo[5] <= dtn.data;
        end
    end
    
    value_fifo_count_matching_ripple_count:
        assert (value_count == Acntripple[1]);
end
// ----------------------------------------------------------------------
// Compare FIFO to reordered values.
// ----------------------------------------------------------------------
always @ (posedge clock) begin
    
    if (line_before0.data_just_matched) begin
        // Need different offset since counting is not applied to just matched data.
    end else begin
    line_value_matching_valuefifo_0:
        assert (!line_before0.addr_valid || line_before0.addr != fixed_A || !line_before0.data_valid || line_before0.data == value_fifo[Acnt[0]-1]);
    end
    if (line_before1.data_just_matched) begin
        // Need different offset since counting is not applied to just matched data.
        line_value_matching_valuefifo_justmatched_1:
            assert (!line_before1.addr_valid || line_before1.addr != fixed_A || !line_before1.data_valid || line_before1.data == value_fifo[Acnt[1]]);
    end else begin
    line_value_matching_valuefifo_1:
        assert (!line_before1.addr_valid || line_before1.addr != fixed_A || !line_before1.data_valid || line_before1.data == value_fifo[Acnt[1]-1]);
    end
    if (line_before2.data_just_matched) begin
        // Need different offset since counting is not applied to just matched data.
        line_value_matching_valuefifo_justmatched_2:
            assert (!line_before2.addr_valid || line_before2.addr != fixed_A || !line_before2.data_valid || line_before2.data == value_fifo[Acnt[2]]);
    end else begin
    line_value_matching_valuefifo_2:
        assert (!line_before2.addr_valid || line_before2.addr != fixed_A || !line_before2.data_valid || line_before2.data == value_fifo[Acnt[2]-1]);
    end
    if (line_before3.data_just_matched) begin
        // Need different offset since counting is not applied to just matched data.
        line_value_matching_valuefifo_justmatched_3:
            assert (!line_before3.addr_valid || line_before3.addr != fixed_A || !line_before3.data_valid || line_before3.data == value_fifo[Acnt[3]]);
    end else begin
    line_value_matching_valuefifo_3:
        assert (!line_before3.addr_valid || line_before3.addr != fixed_A || !line_before3.data_valid || line_before3.data == value_fifo[Acnt[3]-1]);
    end
    if (line_before4.data_just_matched) begin
        // Need different offset since counting is not applied to just matched data.
        line_value_matching_valuefifo_justmatched_4:
            assert (!line_before4.addr_valid || line_before4.addr != fixed_A || !line_before4.data_valid || line_before4.data == value_fifo[Acnt[4]]);
    end else begin
    line_value_matching_valuefifo_4:
        assert (!line_before4.addr_valid || line_before4.addr != fixed_A || !line_before4.data_valid || line_before4.data == value_fifo[Acnt[4]-1]);
    end
    if (line_before5.data_just_matched) begin
        // Need different offset since counting is not applied to just matched data.
        line_value_matching_valuefifo_justmatched_5:
            assert (!line_before5.addr_valid || line_before5.addr != fixed_A || !line_before5.data_valid || line_before5.data == value_fifo[Acnt[5]]);
    end else begin
    line_value_matching_valuefifo_5:
        assert (!line_before5.addr_valid || line_before5.addr != fixed_A || !line_before5.data_valid || line_before5.data == value_fifo[Acnt[5]-1]);
    end
    ripple_value_matching_valuefifo_1:
        assert (!dtn_after0.valid || dtn_after0.from != fixed_A || dtn_after0.data == value_fifo[Acntripple[1]-1]);
    ripple_value_matching_valuefifo_2:
        assert (!dtn_after1.valid || dtn_after1.from != fixed_A || dtn_after1.data == value_fifo[Acntripple[2]-1]);
    ripple_value_matching_valuefifo_3:
        assert (!dtn_after2.valid || dtn_after2.from != fixed_A || dtn_after2.data == value_fifo[Acntripple[3]-1]);
    ripple_value_matching_valuefifo_4:
        assert (!dtn_after3.valid || dtn_after3.from != fixed_A || dtn_after3.data == value_fifo[Acntripple[4]-1]);
    ripple_value_matching_valuefifo_5:
        assert (!dtn_after4.valid || dtn_after4.from != fixed_A || dtn_after4.data == value_fifo[Acntripple[5]-1]);
end
`endif
endmodule
