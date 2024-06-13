module sw_m #(parameter SIZE=1) (
    output wire [SIZE-1:0] y0,
    output wire [SIZE-1:0] y1,
    input wire c,
    input wire [SIZE-1:0] x0,
    input wire [SIZE-1:0] x1
);
    // Switch multiple wires.
    assign y0 = c ? x1 : x0;
    assign y1 = c ? x0 : x1;
endmodule
