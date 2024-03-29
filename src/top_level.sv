// sample top level design
module top_level (
    input        clk,
    reset,
    output logic done
);
  parameter D = 12;
  wire [D-1:0] target,  // jump 
  prog_ctr;

  wire RegDst, MemtoReg, MemWrite, ALUSrc, RegWrite, MoveCtrl;
  wire [1:0] ALUOp;
  wire [2:0] instr;
  wire [7:0] datA, datB, out,  // from RegFile
  muxB, rslt,  // alu output
  immed,  // immediate value
  mem_out_data,  // output from reading data memory
  regfile_dat;  // data passed into regfile for writing
  logic
      sc_o,  // shift/carry output from Alu
      sc_in,  // shift/carry out from/to ALU
      pariQ,  // registered parity flag from ALU
      zeroQ;  // registered zero flag from ALU 
  wire relj;  // from control to PC; relative jump enable
  wire absj = 0;
  wire pari, zero, eq, sc_clr, sc_en;  // immediate switch
  wire reljump_en;
  wire [8:0] mach_code;  // machine code
  wire [2:0] rd_addrA, rd_addrB;  // address pointers to reg_file

  // All types
  assign instr = mach_code[8:6];
  // R type
  // op B A
  assign rd_addrB = mach_code[5:3];
  assign rd_addrA = mach_code[2:0];
  // I type
  assign immed = {2'b0, mach_code[5:0]};

  assign reljump_en = relj && eq;
  assign muxB = ALUSrc ? immed : datB;
  assign regfile_dat = MemtoReg ? mem_out_data : rslt;

  // fetch subassembly
  PC #(
      .D(D)
  )  // D sets program counter width
      pc1 (
      .reset,
      .clk,
      .reljump_en(reljump_en),
      .absjump_en(absj),
      .target,
      .prog_ctr
  );

  // lookup table to facilitate jumps/branches
  PC_LUT #(
      .D(D)
  ) pl1 (
      .addr(out[4:0]),
      .target
  );

  // contains machine code
  instr_ROM ir1 (
      .prog_ctr,
      .mach_code
  );

  // control decoder
  Control ctl1 (
      .instr(instr),
      .RegDst(RegDst),
      .Branch(relj),
      .MemtoReg(MemtoReg),
      .MemWrite(MemWrite),
      .ALUSrc(ALUSrc),
      .RegWrite(RegWrite),
      .MoveCtrl(MoveCtrl),
      .ALUOp
  );

  // When moving, we read from A and write to addr of B
  // Otherwise, always write to OUT (addr 111)
  reg_file #(
      .pw(3)
  ) rf1 (
      .dat_in  (regfile_dat),  // loads, most ops
      .clk,
      .wr_en   (RegWrite),
      .par(pariQ),
      .rd_addrA(rd_addrA),
      .rd_addrB(MoveCtrl ? rd_addrA : rd_addrB), // passthrough register
      .wr_addr (MoveCtrl ? rd_addrB : 'b111),
      .datA_out(datA),
      .datB_out(datB),
      .out_reg(out)
  );


  alu alu1 (
      .alu_cmd(ALUOp),
      .inA    (datA),
      .inB    (muxB),
      // .sc_i   (sc_in),  // output from sc register
      .eq     (eq),
      .rslt,
      // .sc_o   (sc_o),   // input to sc register
      .pari
  );

  dat_mem dm1 (
      .dat_in (datB),         // from reg_file
      .clk,
      .wr_en  (MemWrite),     // stores
      .addr   (datA),
      .dat_out(mem_out_data)
  );

  // registered flags from ALU
  always_ff @(posedge clk) begin
    pariQ <= pari;
    zeroQ <= zero;
    if (sc_clr) sc_in <= 'b0;
    else if (sc_en) sc_in <= sc_o;
  end

  assign done = prog_ctr == 512;

endmodule
