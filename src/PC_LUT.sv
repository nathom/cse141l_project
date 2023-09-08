module PC_LUT #(
    parameter D = 12
) (
    input        [  4:0] addr,   // target 32 values
    output logic [D-1:0] target
);

  always_comb
    case (addr)
      0: target = 55;
      1: target = 153;
      2: target = 16;
      3: target = 130;
      4: target = 28;
      5: target = 22;
      6: target = -470;
      default: target = 'b0;  // hold PC
    endcase




endmodule
