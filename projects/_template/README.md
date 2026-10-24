# Project template

Copy this folder to start a new project:

    cp -r projects/_template projects/02-my-thing

Then rename `src/top.v` and the module inside it, point the testbench at the new
name, and rewrite this README to say what the project does.

Folders starting with `_` are skipped by `make list`, so this template stays out
of the project listing.

## Layout

- `src/` — the design. Synthesizable code only.
- `tb/` — testbench(es). Simulation-only: stimulus, `$display`, `$finish`.
- `project.mk` *(optional)* — per-project make overrides, e.g. `TOP = my_tb`
  when there is more than one root module, or extra `IVFLAGS`.
