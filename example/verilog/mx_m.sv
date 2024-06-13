module mx_m #(parameter SIZE=1) (
    output wire [SIZE-1:0] y,
    input wire c,
    input wire [SIZE-1:0] x0,
    input wire [SIZE-1:0] x1
);
    assign y = c ? x1 : x0;
endmodule
