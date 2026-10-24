`timescale 1ns / 1ps

// Sweeps all four input combinations, prints a truth table, and checks each
// gate against the same function written with operators. 4 combinations x 7
// gates = 28 checks.
module basic_gates_tb;

  reg a, b;
  wire y_and, y_or, y_not_a, y_nand, y_nor, y_xor, y_xnor;

  integer errors = 0;
  integer i;

  basic_gates dut (
      .a(a), .b(b),
      .y_and(y_and), .y_or(y_or), .y_not_a(y_not_a),
      .y_nand(y_nand), .y_nor(y_nor), .y_xor(y_xor), .y_xnor(y_xnor)
  );

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, basic_gates_tb);
  end

  // The design uses primitives, so checking against the operator form is a
  // genuine cross-check rather than a restatement of the same expression.
  task check(input [8*4:1] name, input got, input exp);
    begin
      if (got !== exp) begin
        $display("  FAIL %0s: a=%b b=%b -> %b, expected %b", name, a, b, got, exp);
        errors = errors + 1;
      end
    end
  endtask

  initial begin
    $display("");
    $display("  a b | and or not_a nand nor xor xnor");
    $display("  ----+--------------------------------");

    for (i = 0; i < 4; i = i + 1) begin
      {a, b} = i[1:0];
      #1;

      $display("  %b %b |  %b   %b    %b     %b    %b   %b    %b",
               a, b, y_and, y_or, y_not_a, y_nand, y_nor, y_xor, y_xnor);

      check("and",  y_and,    a & b);
      check("or",   y_or,     a | b);
      check("not",  y_not_a, ~a);
      check("nand", y_nand, ~(a & b));
      check("nor",  y_nor,  ~(a | b));
      check("xor",  y_xor,    a ^ b);
      check("xnor", y_xnor, ~(a ^ b));
    end

    $display("");
    if (errors == 0) begin
      $display("basic_gates_tb: all 28 checks passed");
      $finish;
    end
    else begin
      // $fatal exits non-zero, so a broken gate fails the build rather than
      // scrolling past in the log.
      $fatal(1, "basic_gates_tb: %0d of 28 checks failed", errors);
    end
  end

endmodule
