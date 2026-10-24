# Two testbenches live in tb/, so Icarus cannot infer which is the root.
# Default to the self-checking one; override per run with
#   make run PROJ=02-basic-gates TOP=basic_gates_wave_tb
TOP = basic_gates_tb
