module top_level_tb;

  // Testbench signals
  reg   clk = 0;
  reg   reset = 1;  // Start with reset asserted
  reg   req = 0;
  logic done;

  // Instantiate the DUT (Design Under Test)
  top_level dut (
      .clk  (clk),
      .reset(reset),
      .req  (req),
      .done (done)
  );
  always begin  // continuous loop
    #5ns clk = 1;  // clock tick
    #5ns clk = 0;  // clock tock
    // print count, message, padded message, encrypted message, ASCII of message and encrypted
  end  // continue


  initial begin
    $display("Starting simulation...");
    // Generate clock signal
    // Set reset to 1 for a period of time
    #50ns reset = 0;  // Deassert reset
    $display("Reset to 0");
    // Continue simulation until 'done' is set to 1
    wait (done);

    // Display message and finish simulation
    $display("Simulation finished. 'done' is set to 1.");
    $stop;
  end

endmodule
