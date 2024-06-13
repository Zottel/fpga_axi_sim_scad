module sw (output y0, y1, input c, x0, x1);
    assign y0 = c ? x1 : x0;
    assign y1 = c ? x0 : x1;
endmodule
