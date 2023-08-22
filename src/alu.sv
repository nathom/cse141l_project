// combinational -- no clock
// sample -- change as desired
module alu (
    input        [1:0] alu_cmd,  // ALU instructions
    input        [7:0] inA,
    inB,  // 8-bit wide data path
    input              sc_i,     // shift_carry in
    output logic [7:0] rslt,
    output logic       sc_o,     // shift_carry out
    pari,  // reduction XOR (output)
    zero,  // NOR (output)
    neq  // inA != inB
);

  always_comb begin
    rslt = 'b0;
    sc_o = 'b0;
    zero = !rslt;
    pari = ^rslt;
    neq  = inA != inB;
    case (alu_cmd)
      2'b00:  // add
      rslt = inA + inB;
      2'b01:  // right rotate
      rslt = {inA[0], inA[1:7]};
      2'b10:  // NAND
      rslt = ~(inA & inB);
    endcase
  end

endmodule
