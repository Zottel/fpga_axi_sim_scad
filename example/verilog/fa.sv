module fa (output s, cout, input x1, x2, cin);
    assign s = x1 ^ x2 ^ cin;
    assign cout = x1 & x2 | cin & (x1 ^ cin);
endmodule
