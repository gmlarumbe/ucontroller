# README #

## Overview ##

The IP implements a basic 8-bit microcontoller that reads custom assembly code from an external ROM 
and performs the corresponding microinstructions. RTL and testbenches are written in SystemVerilog.

  * Includes a full-duplex UART with DMA capabilites.
  * Internal memory is divided into register space and general purpose memory.
  * The CPU can decode instructions of 1-byte and 2-bytes.

## Requirements ##

The project makes use of Makefiles to build targets for setup, elaboration, simulation and synthesis.

### Icarus Verilog ###

Icarus Verilog is a Verilog simulation and synthesis tool that supports a good number
of SystemVerilog constructs. 

To download the latest version from GitHub: <https://github.com/steveicarus/iverilog>


### Verilator ###

Verilator is a free and open-source software tool which converts Verilog to a cycle-accurate behavioral model in C++ or SystemC. 
However, in this project it is used only to perform additional extra linting checks.

To download the latest version from GitHub: <https://github.com/verilator/verilator>

### Vivado ###

Synthesis has been tested with Xilinx Vivado 2018.3.

Some scripts expect its installation folder to be at */opt/Xilinx/* if project creation for synthesis targets are being run.

## Elaboration, simulation and synthesis ##

To elaborate/simulate all the submodules and hierarchy top module:

    $ make all_elabs
    $ make all_sims

To elaborate/simulate an standalone submodule:

    $ make top
    $ make tb_top

Waves will be created at the *waves* folder.

To synthesize the IP first a Vivado project needs to be created. To recreate it a TCL is provided. To run its target:

    $ make vivado_proj

To synthesize the IP:

    $ make vivado_syn


### Known Issues ###

Since Icarus Verilog does not have support for SystemVerilog interfaces as module ports, object oriented class-based testbench is not possible.
A free alternative would be Vivado 2018.3 WebPack Edition. Includes a license for device `xc7z010clg225` ([Zynqberry's FPGA](https://shop.trenz-electronic.de/en/TE0726-03M-ZynqBerry-Module-with-Xilinx-Zynq-7010-in-Raspberry-Pi-Form-Faktor)),
and supports SystemVerilog virtual interfaces. As a drawback, simulation seems much slower than with Iverilog.

Formal verification with [SimbiYosys](https://github.com/YosysHQ/SymbiYosys) is not possible either as it does not support SystemVerilog.

