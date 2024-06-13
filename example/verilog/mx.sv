module mx (output y, input c, x0, x1);
    assign y = c ? x1 : x0;
endmodule
