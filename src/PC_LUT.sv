module PC_LUT #(
    parameter D = 12
) (
    input        [  4:0] addr,   // target 32 values
    output logic [D-1:0] target
);

  always_comb
    case (addr)
      0: target = 5;
      1: target = 5;
      2: target = 5;
      3: target = 5;
      4: target = 7;
      5: target = 10;
      6: target = 9;
      7: target = 9;
      8: target = 9;
      9: target = 9;
      10: target = -223;
      default: target = 'b0;  // hold PC
    endcase


endmodule
