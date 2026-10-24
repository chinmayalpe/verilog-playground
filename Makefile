# Build and run any project under projects/ with Icarus Verilog.
#
#   make run PROJ=01-hello-world
#   make wave PROJ=02-counter
#   make list
#
# Each project is self-contained: src/ holds the design, tb/ the testbench.
# A project needing extra flags or an explicit top module can add a
# project.mk setting IVFLAGS or TOP.

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
