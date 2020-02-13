# Makefile

IVERILOG=iverilog
IVERILOG_FLAGS=-g2012 -gassertions -Wall
IVERILOG_CDIR=iver

VVP=vvp
VVP_FLAGS=

VERILATOR=verilator
VERILATOR_FLAGS=--lint-only +1800-2012ext+sv
# VERILATOR_FLAGS=-cdc +1800-2012ext+sv

WAVES_FORMAT=lx2
WAVES_DIR=waves

SCRIPTSDIR=scripts


##############################
# All the targets
##############################
all : all_elabs all_sims

all_sims : alu_sim

all_elabs: alu_elab


##############################
# UART
##############################
uart_rx_sim : uart_rx_elab
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(IVERILOG_CDIR)/tb_uart.compiled src/pkg/global_pkg.sv src/uart/uart_rx.sv src/uart/tb_uart_rx.sv
	$(VVP) $(VVP_FLAGS) $(IVERILOG_CDIR)/tb_uart.compiled -$(WAVES_FORMAT)
	mv tb_uart_rx.$(WAVES_FORMAT) $(WAVES_DIR)

uart_rx_elab : uart_rx_src
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(IVERILOG_CDIR)/uart.compiled src/pkg/global_pkg.sv src/uart/uart_rx.sv
	$(VERILATOR) $(VERILATOR_FLAGS) src/pkg/global_pkg.sv src/uart/uart_rx.sv --top-module uart_rx


uart_rx_src: global_pkg src/uart/uart_rx.sv


uart_tx_sim : uart_tx_elab
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(IVERILOG_CDIR)/tb_uart.compiled src/pkg/global_pkg.sv src/uart/uart_tx.sv src/uart/tb_uart_tx.sv
	$(VVP) $(VVP_FLAGS) $(IVERILOG_CDIR)/tb_uart.compiled -$(WAVES_FORMAT)
	mv tb_uart_tx.$(WAVES_FORMAT) $(WAVES_DIR)

uart_tx_elab : uart_tx_src
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(IVERILOG_CDIR)/uart.compiled src/pkg/global_pkg.sv src/uart/uart_tx.sv
	$(VERILATOR) $(VERILATOR_FLAGS) src/pkg/global_pkg.sv src/uart/uart_tx.sv --top-module uart_tx

uart_tx_src: global_pkg src/uart/uart_tx.sv


##############################
# ALU
##############################
alu_sim : alu_elab
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(IVERILOG_CDIR)/tb_alu.compiled src/pkg/global_pkg.sv src/alu/alu.sv src/alu/tb_alu.sv
	$(VVP) $(VVP_FLAGS) $(IVERILOG_CDIR)/tb_alu.compiled -$(WAVES_FORMAT)
	mv tb_alu.$(WAVES_FORMAT) $(WAVES_DIR)

alu_elab : alu_src
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(IVERILOG_CDIR)/alu.compiled src/pkg/global_pkg.sv src/alu/alu.sv
	$(VERILATOR) $(VERILATOR_FLAGS) src/pkg/global_pkg.sv src/alu/alu.sv --top-module alu

alu_src: global_pkg src/alu/alu.sv


##############################
# Global Package
##############################
global_pkg : src/pkg/global_pkg.sv


##############################
# Setup
##############################
setup: check_req
	mkdir -p $(IVERILOG_CDIR)
	mkdir -p $(WAVES_DIR)

clean:
	rm -rf $(IVERILOG_CDIR)
	rm -rf $(WAVES_DIR)
	rm -rf .Xil

check_req:
	$(SCRIPTSDIR)/check_requirements.sh
