// cache memory/register file
// default address pointer width = 4, for 16 registers
module reg_file #(
    parameter pw = 3
) (
    input        [   7:0] dat_in,
    input                 clk,
    input                 wr_en,    // write enable
    input        [pw-1:0] wr_addr,  // write address pointer
    input                 par,      // to set core[6] = parity
    rd_addrA,  // read address pointers
    rd_addrB,
    output logic [   7:0] datA_out, // read data
    datB_out
);

  logic [7:0] core[2**pw];  // 2-dim array  8 wide  16 deep

  // reads are combinational
  always_comb begin
    if (rd_addrA == 6) datA_out = {7'b0, par};
    else datA_out = core[rd_addrA];
  end

  always_comb begin
    if (rd_addrB == 6) datB_out = {7'b0, par};
    else datB_out = core[rd_addrB];
  end

  // writes are sequential (clocked)
  always_ff @(posedge clk)
    if (wr_en)  // anything but stores or no ops
      core[wr_addr] <= dat_in;

endmodule
/*
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
*/
