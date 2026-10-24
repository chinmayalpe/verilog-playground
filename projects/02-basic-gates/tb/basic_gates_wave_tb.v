`timescale 1ns / 1ps

// Waveform-oriented companion to basic_gates_tb.
//
// basic_gates_tb proves the gates are correct and exits in 4 ns, which makes a
// cramped trace. This one exists to be *looked at*: a slow clock, each input
// combination held for a full period, and two passes through the sweep so the
// pattern is plainly periodic.
//
//   make wave PROJ=02-basic-gates TOP=basic_gates_wave_tb
//   .\run.ps1 02-basic-gates -Wave -Top basic_gates_wave_tb
module basic_gates_wave_tb;

  localparam integer CLK_PERIOD = 20;   // ns, so 50 MHz
  localparam integer PASSES     = 2;    // full sweeps of {a,b}

  reg       clk   = 1'b0;
  reg [1:0] count = 2'b00;

  // count walks 00 -> 01 -> 10 -> 11 and wraps, so a is the high bit.
  wire a = count[1];
  wire b = count[0];

  wire y_and, y_or, y_not_a, y_nand, y_nor, y_xor, y_xnor;

  basic_gates dut (
      .a(a), .b(b),
      .y_and(y_and), .y_or(y_or), .y_not_a(y_not_a),
      .y_nand(y_nand), .y_nor(y_nor), .y_xor(y_xor), .y_xnor(y_xnor)
  );

  always #(CLK_PERIOD / 2) clk = ~clk;

  always @(posedge clk) count <= count + 1'b1;

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, basic_gates_wave_tb);
  end

  initial begin
    $display("basic_gates_wave_tb: %0d ns of stimulus -> wave.vcd",
             PASSES * 4 * CLK_PERIOD);
    $display("  {a,b} count up once per clock; every output follows on the same edge.");
    #(PASSES * 4 * CLK_PERIOD);
    $display("basic_gates_wave_tb: done");
    $finish;
  end

endmodule
