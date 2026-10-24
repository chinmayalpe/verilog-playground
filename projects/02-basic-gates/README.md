# 02 — Basic Gates

All seven basic logic gates — AND, OR, NOT, NAND, NOR, XOR, XNOR — wired to the
same two inputs, so one sweep of `{a,b}` exercises every one of them.

The design uses Verilog's built-in **gate primitives**:

    and  u_and  (y_and, a, b);     // output first, then inputs

The testbench checks each output against the same function written with the
**operators** (`&`, `|`, `~`, `^`). Two different spellings of the same logic
means a real cross-check, not a restatement — if the primitive and the operator
disagree, one of them is wrong.

    make run PROJ=02-basic-gates
    .\run.ps1 02-basic-gates

Expected output:

      a b | and or not_a nand nor xor xnor
      ----+--------------------------------
      0 0 |  0   0    1     1    1   0    1
      0 1 |  0   1    1     1    0   1    0
      1 0 |  0   1    0     1    0   1    0
      1 1 |  1   1    0     0    0   0    1

    basic_gates_tb: all 28 checks passed

4 input combinations × 7 gates = 28 checks. A failure names the gate and prints
both values:

    FAIL xor: a=0 b=1 -> 0, expected 1

and ends in `$fatal`, which exits non-zero so a broken gate fails the build
instead of scrolling past in the log.

## Waveform

    make wave PROJ=02-basic-gates
    .\run.ps1 02-basic-gates -Wave

Each combination is held for 1 ns, so the whole sweep is 4 ns wide.

## Notes

`not` is the one primitive here with a single input, which is why only `a` is
inverted — `y_not_a`. Add `not u_not_b (y_not_b, b);` if both are wanted.

Gate primitives take any number of inputs: `and u (y, a, b, c, d);` is a 4-input
AND. Worth trying once the two-input case is clear.
