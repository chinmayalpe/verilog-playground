# verilog-playground

A repo which contains small projects in verilog made for fun and learning.

Each project is a self-contained folder under `projects/`, sharing one build
setup at the repo root.

## Layout

    projects/
      01-hello-world/     a project: src/, optional tb/, its own README
        src/              the design (synthesizable code)
        README.md
      _template/          copy this to start a new project
        src/
        tb/               testbench: stimulus, $display, $finish
    Makefile              build + run any project
    run.ps1               same thing for Windows without make
    build/                simulation output, git-ignored

Folders beginning with `_` are not projects.

## Running

Pick a project with `PROJ`:

    make run PROJ=01-hello-world    # compile and simulate
    make wave PROJ=01-hello-world   # simulate, then open the VCD in GTKWave
    make list                       # show available projects
    make clean PROJ=01-hello-world  # drop that project's build output

On Windows without `make`:

    .\run.ps1 01-hello-world
    .\run.ps1 01-hello-world -Wave
    .\run.ps1 -List
    .\run.ps1 01-hello-world -Clean

Both compile every `.v` under the project's `src/` and `tb/` into
`build/<project>/sim.vvp` and run it from that directory, so waveforms land in
`build/` rather than the repo root.

## Adding a project

    cp -r projects/_template projects/02-counter

Rename `src/top.v` and its module, point `tb/top_tb.v` at the new name, and
update the project's README. Nothing needs registering — the build discovers
projects by folder name.

If a project ends up with more than one root module, Icarus can't guess the
entry point; add a `project.mk` naming it:

    TOP = counter_tb

The same file can override `IVFLAGS` for a project that needs extra flags.

## Toolchain

Simulation uses [Icarus Verilog](https://steveicarus.github.io/iverilog/), which
bundles [GTKWave](https://gtkwave.sourceforge.net/) for waveforms:

    winget install Icarus.Verilog

The installer does not touch `PATH`. Add both of these to it, then reopen the
shell:

    C:\iverilog\bin
    C:\iverilog\gtkwave\bin

Verify with `iverilog -V`. Tested against Icarus Verilog 12.0.
