`timescale 1ns / 1ps

// Starting point for a new design -- rename the module and replace the body.
module top (
    input  wire a,
    input  wire b,
    output wire y
);

  assign y = a & b;

endmodule
