module PC_LUT #(
    parameter D = 12
) (
    input        [  4:0] addr,   // target 32 values
    output logic [D-1:0] target
);

  always_comb
    case (addr)
      0: target = -258;
      1: target = 55;
      2: target = 153;
      3: target = 16;
      4: target = 130;
      5: target = 28;
      6: target = 22;
      7: target = -470;
      8: target = 5;
      9: target = 5;
      10: target = 5;
      11: target = 5;
      12: target = 7;
      13: target = 10;
      14: target = 6;
      15: target = 134;
      16: target = 9;
      17: target = 9;
      18: target = 9;
      19: target = 9;
      20: target = -249;
      default: target = 'b0;  // hold PC
    endcase

endmodule
