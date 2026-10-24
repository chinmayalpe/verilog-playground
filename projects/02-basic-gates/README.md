# 02 — Basic Gates

All seven basic logic gates — AND, OR, NOT, NAND, NOR, XOR, XNOR — wired to the
same two inputs, so one sweep of `{a,b}` exercises every one of them.

The design uses Verilog's built-in **gate primitives**:

    and  u_and  (y_and, a, b);     // output first, then inputs

## Two testbenches

| Testbench | Purpose | Duration |
| --- | --- | --- |
| `basic_gates_tb` | self-checking: proves the logic is right | 4 ns |
| `basic_gates_wave_tb` | waveform: produces a trace worth looking at | 160 ns |

Both are roots, so Icarus cannot infer which to elaborate. `project.mk` names
the self-checking one as the default; pick the other per run with `TOP=` or
`-Top`.

### Checking the logic

    make run PROJ=02-basic-gates
    .\run.ps1 02-basic-gates

The testbench checks each output against the same function written with the
**operators** (`&`, `|`, `~`, `^`). Two different spellings of the same logic
means a real cross-check, not a restatement — if the primitive and the operator
disagree, one of them is wrong.

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

### Looking at the waveform

    make wave PROJ=02-basic-gates TOP=basic_gates_wave_tb
    .\run.ps1 02-basic-gates -Wave -Top basic_gates_wave_tb

`basic_gates_tb` is over in 4 ns, which makes a cramped trace. The waveform
testbench trades speed for legibility: a 20 ns clock, `{a,b}` driven by a 2-bit
counter so each combination is held for a full period, and two passes through
the sweep so the pattern is plainly periodic. 160 ns total.

Signals worth putting side by side in GTKWave:

- `clk` — the time reference everything else moves on.
- `count[1:0]`, or `a` and `b` — the stimulus.
- the seven `y_*` outputs — each changes on the same edge as the inputs, since
  the gates are combinational. Any delay you see is the viewer, not the logic.

Reading it against the truth table above: `y_and` is high only in the last
quarter of each pass, `y_or` only low in the first, and `y_xor` / `y_xnor` are
exact inverses of each other throughout.

Drop `-Wave` / use `make run` to produce `build/02-basic-gates/wave.vcd`
without opening the viewer.

## Notes

`not` is the one primitive here with a single input, which is why only `a` is
inverted — `y_not_a`. Add `not u_not_b (y_not_b, b);` if both are wanted.

Gate primitives take any number of inputs: `and u (y, a, b, c, d);` is a 4-input
AND. Worth trying once the two-input case is clear.
