// combinational -- no clock
// sample -- change as desired
module alu (
    input        [2:0] alu_cmd,  // ALU instructions
    input        [7:0] inA,
    inB,  // 8-bit wide data path
    input              sc_i,     // shift_carry in
    output logic [7:0] rslt,
    output logic       sc_o,     // shift_carry out
    pari,  // reduction XOR (output)
    zero  // NOR (output)
);

  always_comb begin
    rslt = 'b0;
    sc_o = 'b0;
    zero = !rslt;
    pari = ^rslt;
    case (alu_cmd)
      3'b000: // add
      begin
        rslt = inA + inB;
        sc_o = rslt[8];
      end
      3'b001: // left rotate
      begin
        rslt = {inA[6:0], inA[7]};
        sc_o = rslt[8];
      end
      3'b010: // NAND
      begin
        rslt = ~(inA & inB);
        sc_o = sc_i;  // No shift operation for NAND
      end
      3'b011: // subtract
      begin
        rslt = inA - inB;
        sc_o = rslt[8];
      end
    endcase
  end

endmodule
