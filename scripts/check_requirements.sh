#!/bin/sh

# Check requirements
command -v iverilog > /dev/null 2>&1 || { echo >&2 "Error: iverilog not installed. Aborting."; exit 1; }
command -v iverilog-vpi > /dev/null 2>&1 || { echo >&2 "Error: iverilog-vpi not installed. Aborting."; exit 1; }
command -v vvp > /dev/null 2>&1 || { echo >&2 "Error: vvp not installed. Aborting."; exit 1; }
command -v gtkwave > /dev/null 2>&1 || { echo >&2 "Error: gtkwave not installed. Aborting."; exit 1; }

echo "Icarus Verilog & GtkWave available!"
