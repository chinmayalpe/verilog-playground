`timescale 1ns / 1ps

module top_tb;

  reg  a, b;
  wire y;
  integer errors = 0;

  top dut (.a(a), .b(b), .y(y));

  // Waveform dump -- `make wave PROJ=<name>` and `run.ps1 -Wave` look for this.
  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, top_tb);
  end

  task check(input exp);
    begin
      if (y !== exp) begin
        $display("FAIL: a=%b b=%b -> y=%b, expected %b", a, b, y, exp);
        errors = errors + 1;
      end
    end
  endtask

  initial begin
    a = 0; b = 0; #1 check(1'b0);
    a = 0; b = 1; #1 check(1'b0);
    a = 1; b = 0; #1 check(1'b0);
    a = 1; b = 1; #1 check(1'b1);

    if (errors == 0) $display("top_tb: all checks passed");
    else             $display("top_tb: %0d check(s) failed", errors);
    $finish;
  end

  // For a sequential design, drive a clock instead:
  //   reg clk = 0;
  //   always #5 clk = ~clk;   // 100 MHz

endmodule
