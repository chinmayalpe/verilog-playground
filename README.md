# verilog-playground

A repo which contains small projects in verilog made for fun and learning.

Each project is a self-contained folder under `projects/`, sharing one build
setup at the repo root.

## Layout

    projects/
      01-hello-world/     a project: src/, optional tb/, its own README
        src/              the design (synthesizable code)
        README.md
      02-basic-gates/     all seven gates, logic + waveform testbenches
        src/
        tb/
        README.md
        project.mk        names the default top, since tb/ has two
      _template/          copy this to start a new project
        src/
        tb/               testbench: stimulus, $display, $finish
    Makefile              build + run any project
    run.ps1               same thing for Windows without make
    build/                simulation output, git-ignored

Folders beginning with `_` are not projects.

## Setup (once)

Simulation uses [Icarus Verilog](https://steveicarus.github.io/iverilog/), which
bundles [GTKWave](https://gtkwave.sourceforge.net/) for waveforms.

1. Install it:

       winget install Icarus.Verilog

2. The installer does not touch `PATH`. Add both of these:

       C:\iverilog\bin
       C:\iverilog\gtkwave\bin

3. Reopen the terminal, then check it took:

       iverilog -V

Tested against Icarus Verilog 12.0.

### If PowerShell refuses to run run.ps1

A default Windows install blocks local scripts, so `.\run.ps1` fails with
*"running scripts is disabled on this system"*. Either allow local scripts once:

    Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

or bypass it per run, changing nothing:

    powershell -ExecutionPolicy Bypass -File .\run.ps1 02-basic-gates

### Optional: make

`run.ps1` needs nothing beyond Icarus. The `make` commands additionally need
GNU Make:

    winget install ezwinports.make

The Makefile's recipes are POSIX, and Windows make quietly falls back to
`cmd.exe`, which cannot run them — so it pins its shell to Git for Windows'
`sh.exe`. Git for Windows is therefore required for the `make` path; it is
already there if you use Git Bash. If Git lives outside `C:\Program Files\Git`,
pass `make SHELL=/path/to/sh`.

Tested with GNU Make 4.4.1 from both PowerShell and Git Bash.

## Running a project

1. Open a terminal at the repo root (`D:\Practice\Verilog`).
2. List what's available:

       make list            # or:  .\run.ps1 -List

3. Run one by name:

       make run PROJ=01-hello-world
       .\run.ps1 01-hello-world          # Windows, no make needed

Output goes to `build/<project>/`. Each run recompiles every `.v` under that
project's `src/` and `tb/` into `build/<project>/sim.vvp`, then simulates from
inside that directory — so waveforms land in `build/`, never the repo root.

### All commands

| What | make | PowerShell |
| --- | --- | --- |
| Compile and simulate | `make run PROJ=<name>` | `.\run.ps1 <name>` |
| Simulate, then open waveform | `make wave PROJ=<name>` | `.\run.ps1 <name> -Wave` |
| Pick the top module | `make run PROJ=<name> TOP=<tb>` | `.\run.ps1 <name> -Top <tb>` |
| List projects | `make list` | `.\run.ps1 -List` |
| Delete one project's output | `make clean PROJ=<name>` | `.\run.ps1 <name> -Clean` |
| Delete all output | `make clean-all` | — |

`make` defaults to `PROJ=01-hello-world`, as does `run.ps1` with no argument.

`-Wave` / `make wave` only opens something if the testbench dumps a VCD, which
needs `$dumpfile("wave.vcd");` and `$dumpvars;` in an `initial` block.

## Projects

### 01-hello-world

The obligatory first program: prints a message and exits. No ports, no clock and
no testbench — `hello.v` drives itself from an `initial` block.

    make run PROJ=01-hello-world
    .\run.ps1 01-hello-world

Expected output:

    Hello, World Chinmay
    .../hello.v:5: $finish called at 0 (1s)

The second line is just Icarus reporting where `$finish` was hit, not an error.
The path is relative under `make`, absolute under `run.ps1`.

### 02-basic-gates

All seven basic gates — AND, OR, NOT, NAND, NOR, XOR, XNOR — on shared inputs,
built from Verilog's gate primitives and cross-checked in the testbench against
the operator form of the same logic.

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

It ships a second testbench, `basic_gates_wave_tb`, built for waveform viewing
rather than speed — a 20 ns clock and each input combination held a full period:

    make wave PROJ=02-basic-gates TOP=basic_gates_wave_tb
    .\run.ps1 02-basic-gates -Wave -Top basic_gates_wave_tb

A failing gate is named with both values and ends in `$fatal`, so the build
fails rather than the error scrolling past. See the project's README for detail.

### _template (not a project)

A 2-input AND gate with a self-checking testbench. Not interesting in itself,
but it's the fastest way to confirm a fresh install works, since it exercises
the testbench and waveform paths that `01-hello-world` doesn't:

    make run PROJ=_template
    .\run.ps1 _template

Expected output:

    VCD info: dumpfile wave.vcd opened for output.
    top_tb: all checks passed

Then `make wave PROJ=_template` opens that VCD in GTKWave.

## Adding a project

1. Copy the template:

       cp -r projects/_template projects/02-counter

2. Rename `src/top.v` and the module inside it.
3. Point `tb/top_tb.v` at the new module name.
4. Rewrite that project's `README.md` to say what it does.
5. Run it — nothing needs registering, the build finds projects by folder name:

       make run PROJ=02-counter

If a project ends up with more than one root module, Icarus can't guess the
entry point; add a `projects/<name>/project.mk` naming it:

    TOP = counter_tb

The same file can override `IVFLAGS` for a project needing extra flags.
