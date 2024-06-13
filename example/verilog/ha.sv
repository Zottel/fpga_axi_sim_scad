module ha (output s, c, input x1, x2);
    assign s = x1 ^ x2;
    assign c = x1 & x2;
endmodule
