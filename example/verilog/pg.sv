module pg (output p, g, input g1, p1, g2, p2);
    assign p = p2 & p1;
    assign g = g2 | (p2 & g1);
endmodule
