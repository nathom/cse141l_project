module alu_tb;

  // Inputs
  reg [1:0] alu_cmd;
  reg [5:0] inA, inB;
  reg sc_i;

  // Outputs
  wire [5:0] rslt;
  wire sc_o;
  wire pari;
  wire zero;
  wire neq;

  // Instantiate the ALU module
  alu alu_inst (
      .alu_cmd(alu_cmd),
      .inA(inA),
      .inB(inB),
      .sc_i(sc_i),
      .rslt(rslt),
      .sc_o(sc_o),
      .pari(pari),
      .zero(zero),
      .neq(neq)
  );

  initial begin
    $monitor(
        "Time=%0t || ALU_cmd=%b, inA=%b, inB=%b, sc_i=%b || rslt=%b, sc_o=%b, pari=%b, zero=%b, neq=%b",
        $time, alu_cmd, inA, inB, sc_i, rslt, sc_o, pari, zero, neq);

    // Test cases
    alu_cmd = 2'b00;  // Add
    inA = 6'b101010;
    inB = 6'b110011;
    sc_i = 1'b0;
    #10;

    alu_cmd = 2'b01;  // Right rotate
    inA = 6'b101010;
    inB = 6'b001001;
    sc_i = 1'b0;
    #10;

    alu_cmd = 2'b10;  // NAND
    inA = 6'b101010;
    inB = 6'b110011;
    sc_i = 1'b0;
    #10;

    alu_cmd = 2'b11;  // NOP
    inA = 6'b101010;
    inB = 6'b000000;
    sc_i = 1'b0;
    #10;

    $finish;
  end

endmodule
