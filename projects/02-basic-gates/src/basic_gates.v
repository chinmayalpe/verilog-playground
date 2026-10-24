`timescale 1ns / 1ps

// The seven basic logic gates, all driven from the same two inputs, so one
// exhaustive sweep of {a,b} exercises every one of them.
//
// Built from Verilog's built-in gate primitives rather than the &, | and ~
// operators -- for these gates the primitives are the more literal spelling,
// and it leaves the operators free for the testbench to check against.
module basic_gates (
    input  wire a,
    input  wire b,
    output wire y_and,
    output wire y_or,
    output wire y_not_a,
    output wire y_nand,
    output wire y_nor,
    output wire y_xor,
    output wire y_xnor
);

  // Primitive instances take the output first, then the inputs.
  and  u_and  (y_and,   a, b);
  or   u_or   (y_or,    a, b);
  not  u_not  (y_not_a, a);
  nand u_nand (y_nand,  a, b);
  nor  u_nor  (y_nor,   a, b);
  xor  u_xor  (y_xor,   a, b);
  xnor u_xnor (y_xnor,  a, b);

endmodule
