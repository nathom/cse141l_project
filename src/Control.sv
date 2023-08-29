// control decoder
module Control #(
    parameter opwidth = 2,
    mcodebits = 3
) (
    input [mcodebits-1:0] instr,  // subset of machine code (any width you need)
    output logic RegDst,
    Branch,
    MemtoReg,
    MemWrite,
    ALUSrc,
    RegWrite,
    MoveCtrl,
    output logic [opwidth-1:0] ALUOp
);  // for up to 8 ALU operations

  always_comb begin
    // defaults
    RegDst   = 'b0;  // 1: not in place  just leave 0
    Branch   = 'b0;  // 1: branch (jump)
    MemWrite = 'b0;  // 1: store to memory
    ALUSrc   = 'b0;  // 1: immediate  0: second reg file output
    RegWrite = 'b1;  // 0: for store or no op  1: most other operations 
    MemtoReg = 'b0;  // 1: load -- route memory instead of ALU to reg_file data in
    ALUOp    = 2'b11;  // y = a+0;
    MoveCtrl = 'b0; // 1: if mov, 0: otherwise
    // sample values only -- use what you need
    case (instr)  // override defaults with exceptions
      /* All instructions:
      *
      * R type:
      * 000: add
      * 001: right rotate
      * 010: NAND
      * 011: load
      * 100: store
      * 101: move
      * 110: BNE
      * J type:
      * 111: SET
      */
      'b000: begin  // add
        ALUOp = 'b00;  // y = a+b
      end

      'b001: begin  // right rotate
        ALUOp = 'b01;
      end

      'b010: begin  // NAND
        ALUOp = 'b10;
      end

      'b011: begin  // load
        MemtoReg = 'b1;
        MoveCtrl = 'b1;
      end

      // Stores value in r1 to address in r0
      // mem[r0] = r1
      // STR r1, r0
      'b100: begin
        // ALUOp = 'b111;
        MemWrite = 'b1;
        RegWrite = 'b0;
      end

      // Moves value from r0 to r1
      // mov r1, r0
      'b101: begin
        MoveCtrl = 'b1;
      end

      // beq r0, r1
      // branches to OUT if r0 == r1
      'b110: begin
        Branch = 'b1;
      end

      // set imm
      // sets OUT register to imm
      'b111: begin
        ALUSrc = 'b1;
      end
    endcase

  end

endmodule
