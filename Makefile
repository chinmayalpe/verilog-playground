# Build and run any project under projects/ with Icarus Verilog.
#
#   make run PROJ=01-hello-world
#   make wave PROJ=02-counter
#   make list
#
# Each project is self-contained: src/ holds the design, tb/ the testbench.
# A project needing extra flags or an explicit top module can add a
# project.mk setting IVFLAGS or TOP.

# GNU Make on Windows reports SHELL as a bare "sh.exe" even when no sh is on
# PATH, then silently falls back to cmd.exe -- which has none of the POSIX
# tools these recipes use. So pin SHELL to Git for Windows' sh instead of
# trusting the default. The 8.3 short paths dodge the space in "Program Files",
# which make's $(wildcard) cannot escape. Override with `make SHELL=...` if Git
# lives somewhere else.
ifeq ($(OS),Windows_NT)
  WIN_SH := $(firstword $(wildcard C:/PROGRA~1/Git/usr/bin/sh.exe \
                                   C:/PROGRA~2/Git/usr/bin/sh.exe))
  ifeq ($(WIN_SH),)
    $(error No POSIX shell found. Install Git for Windows, run make from Git \
            Bash, or pass SHELL=/path/to/sh)
  endif
  SHELL := $(WIN_SH)
  .SHELLFLAGS := -c
  # sh.exe inherits PATH from the caller, which on PowerShell/cmd lacks the
  # coreutils sitting next to it, so ls/rm/mkdir/test would not resolve.
  export PATH := $(dir $(WIN_SH)):$(PATH)
endif

PROJ ?= 01-hello-world
PROJ_DIR := projects/$(PROJ)
BUILD := build/$(PROJ)

IVERILOG ?= iverilog
VVP ?= vvp
GTKWAVE ?= gtkwave
IVFLAGS ?= -g2012 -Wall

# Optional per-project overrides (IVFLAGS, TOP, ...).
-include $(PROJ_DIR)/project.mk

SRCS := $(wildcard $(PROJ_DIR)/src/*.v) $(wildcard $(PROJ_DIR)/tb/*.v)
TOPFLAG := $(if $(TOP),-s $(TOP),)

.PHONY: all build run wave list clean clean-all

all: build

$(BUILD)/sim.vvp: $(SRCS)
	@test -n "$(strip $(SRCS))" || { echo "No .v files under $(PROJ_DIR)/{src,tb} -- is PROJ=$(PROJ) right? Try 'make list'."; exit 1; }
	@mkdir -p $(BUILD)
	$(IVERILOG) $(IVFLAGS) $(TOPFLAG) -o $@ $(SRCS)

build: $(BUILD)/sim.vvp

# vvp runs inside the build dir so any $dumpfile output lands there, not in the repo root.
run: build
	cd $(BUILD) && $(VVP) sim.vvp

wave: run
	@test -f $(BUILD)/wave.vcd || { echo "No $(BUILD)/wave.vcd -- add \$$dumpfile(\"wave.vcd\"); and \$$dumpvars; to the testbench."; exit 1; }
	$(GTKWAVE) $(BUILD)/wave.vcd

list:
	@ls -1 projects | grep -v '^_'

clean:
	rm -rf $(BUILD)

clean-all:
	rm -rf build
