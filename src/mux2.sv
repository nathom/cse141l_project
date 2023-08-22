module mux2 #(
    parameter width = 6
) (
    input logic [width-1:0] a,
    input logic [width-1:0] b,
    input logic sel,
    output logic [width-1:0] y
);

  always_comb y = (sel == 1'b0) ? a : b;

endmodule
