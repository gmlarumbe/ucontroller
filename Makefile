# Makefile

IVERILOG=iverilog
IVERILOG_FLAGS=-g2012 -gassertions -Wall
IVERILOG_CDIR=iver

VVP=vvp
VVP_FLAGS=

VERILATOR=verilator
VERILATOR_FLAGS=--lint-only +1800-2012ext+sv

WAVES_FORMAT=lx2
WAVES_DIR=waves

SCRIPTSDIR=scripts

UNISIMS_DIR=vivado/data/verilog/src/unisims

##############################
# All the targets
##############################
all : all_elabs all_sims

all_sims : alu_sim uart_sim ram_sim dma_sim

all_elabs: alu_elab uart_elab ram_elab dma_elab


##############################
# DMA
##############################
dma_rx_sim : dma_rx_elab
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(IVERILOG_CDIR)/tb_dma_rx.compiled -y$(UNISIMS_DIR) src/pkg/global_pkg.sv src/dma/dma_rx.sv src/dma/tb_dma_rx.sv src/uart/sreg.sv src/uart/uart_rx.sv src/uart/uart_tx.sv src/uart/uart.sv src/uart/fifo_generator_0_sim_netlist.v src/uart/fifo_wrapper.sv
	$(VVP) $(VVP_FLAGS) $(IVERILOG_CDIR)/tb_dma_rx.compiled -$(WAVES_FORMAT)
	mv tb_dma_rx.$(WAVES_FORMAT) $(WAVES_DIR)

dma_rx_elab : dma_rx_src
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(IVERILOG_CDIR)/dma_rx.compiled src/pkg/global_pkg.sv src/dma/dma_rx.sv
	$(VERILATOR) $(VERILATOR_FLAGS) src/pkg/global_pkg.sv src/dma/dma_rx.sv

dma_rx_src: global_pkg src/dma/dma_rx.sv 


dma_tx_sim : dma_tx_elab
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(IVERILOG_CDIR)/tb_dma_tx.compiled src/pkg/global_pkg.sv src/dma/dma_tx.sv src/dma/tb_dma_tx.sv src/uart/uart_tx.sv
	$(VVP) $(VVP_FLAGS) $(IVERILOG_CDIR)/tb_dma_tx.compiled -$(WAVES_FORMAT)
	mv tb_dma_tx.$(WAVES_FORMAT) $(WAVES_DIR)

dma_tx_elab : dma_tx_src
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(IVERILOG_CDIR)/dma_tx.compiled src/pkg/global_pkg.sv src/dma/dma_tx.sv
	$(VERILATOR) $(VERILATOR_FLAGS) src/pkg/global_pkg.sv src/dma/dma_tx.sv

dma_tx_src: global_pkg src/dma/dma_tx.sv 


##############################
# RAM
##############################
ram_sim : ram_elab
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(IVERILOG_CDIR)/tb_ram.compiled src/pkg/global_pkg.sv src/ram/ram.sv src/ram/gp_ram.sv src/ram/regs_ram.sv src/ram/tb_ram.sv src/misc/bin2bcd.sv
	$(VVP) $(VVP_FLAGS) $(IVERILOG_CDIR)/tb_ram.compiled -$(WAVES_FORMAT)
	mv tb_ram.$(WAVES_FORMAT) $(WAVES_DIR)

ram_elab : ram_src
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(IVERILOG_CDIR)/ram.compiled src/pkg/global_pkg.sv src/ram/ram.sv src/ram/gp_ram.sv src/ram/regs_ram.sv src/misc/bin2bcd.sv
	$(VERILATOR) $(VERILATOR_FLAGS) src/pkg/global_pkg.sv src/ram/ram.sv src/ram/gp_ram.sv src/ram/regs_ram.sv src/misc/bin2bcd.sv --top-module ram

ram_src: global_pkg src/ram/ram.sv src/ram/gp_ram.sv src/ram/regs_ram.sv src/misc/bin2bcd.sv



##############################
# UART
##############################
uart_sim : uart_elab
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(IVERILOG_CDIR)/tb_uart.compiled -y$(UNISIMS_DIR) src/pkg/global_pkg.sv src/uart/sreg.sv src/uart/uart_rx.sv src/uart/uart_tx.sv src/uart/uart.sv src/uart/fifo_generator_0_sim_netlist.v src/uart/fifo_wrapper.sv src/uart/tb_uart.sv
	$(VVP) $(VVP_FLAGS) $(IVERILOG_CDIR)/tb_uart.compiled -$(WAVES_FORMAT)
	mv tb_uart.$(WAVES_FORMAT) $(WAVES_DIR)

uart_elab : uart_src
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(IVERILOG_CDIR)/uart.compiled -y$(UNISIMS_DIR) src/pkg/global_pkg.sv src/uart/sreg.sv src/uart/uart_rx.sv src/uart/uart_tx.sv src/uart/uart.sv src/uart/fifo_generator_0_sim_netlist.v src/uart/fifo_wrapper.sv
	# Some constructs of the unisims library are not supported by Verilator ()
	# $(VERILATOR) $(VERILATOR_FLAGS) src/pkg/global_pkg.sv src/uart/sreg.sv src/uart/uart_rx.sv src/uart/uart_tx.sv src/uart/uart.sv src/uart/fifo_generator_0_sim_netlist.v src/uart/fifo_wrapper.sv --top-module uart


uart_src: global_pkg src/uart/sreg.sv src/uart/uart_rx.sv src/uart/uart_tx.sv src/uart/uart.sv src/uart/fifo_generator_0_sim_netlist.v src/uart/fifo_wrapper.sv


uart_rx_sim : uart_rx_elab
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(IVERILOG_CDIR)/tb_uart_rx.compiled src/pkg/global_pkg.sv src/uart/uart_rx.sv src/uart/tb_uart_rx.sv
	$(VVP) $(VVP_FLAGS) $(IVERILOG_CDIR)/tb_uart_rx.compiled -$(WAVES_FORMAT)
	mv tb_uart_rx.$(WAVES_FORMAT) $(WAVES_DIR)

uart_rx_elab : uart_rx_src
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(IVERILOG_CDIR)/uart_rx.compiled src/pkg/global_pkg.sv src/uart/uart_rx.sv
	$(VERILATOR) $(VERILATOR_FLAGS) src/pkg/global_pkg.sv src/uart/uart_rx.sv --top-module uart_rx


uart_rx_src: global_pkg src/uart/uart_rx.sv


uart_tx_sim : uart_tx_elab
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(IVERILOG_CDIR)/tb_uart_tx.compiled src/pkg/global_pkg.sv src/uart/uart_tx.sv src/uart/tb_uart_tx.sv
	$(VVP) $(VVP_FLAGS) $(IVERILOG_CDIR)/tb_uart_tx.compiled -$(WAVES_FORMAT)
	mv tb_uart_tx.$(WAVES_FORMAT) $(WAVES_DIR)

uart_tx_elab : uart_tx_src
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(IVERILOG_CDIR)/uart_tx.compiled src/pkg/global_pkg.sv src/uart/uart_tx.sv
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
# MISC
##############################
misc_sim : misc_elab
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(IVERILOG_CDIR)/tb_misc.compiled src/pkg/global_pkg.sv src/misc/bin2bcd.sv src/misc/tb_bin2bcd.sv
	$(VVP) $(VVP_FLAGS) $(IVERILOG_CDIR)/tb_misc.compiled -$(WAVES_FORMAT)
	mv tb_misc.$(WAVES_FORMAT) $(WAVES_DIR)

misc_elab : misc_src
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(IVERILOG_CDIR)/misc.compiled src/misc/bin2bcd.sv
	$(VERILATOR) $(VERILATOR_FLAGS) src/pkg/global_pkg.sv src/misc/bin2bcd.sv --top-module bin2bcd

misc_src: global_pkg src/misc/bin2bcd.sv



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
