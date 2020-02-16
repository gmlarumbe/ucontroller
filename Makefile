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


## Commands for current targets
LINT_CMD    = $(VERILATOR) $(VERILATOR_FLAGS) $^
COMPILE_CMD = $(IVERILOG) $(IVERILOG_FLAGS) -o $(IVERILOG_CDIR)/$@.compiled $^
SIM_CMD	    = $(VVP) $(VVP_FLAGS) $(IVERILOG_CDIR)/$@.compiled -$(WAVES_FORMAT)
WAVES_CMD   = mv $@.$(WAVES_FORMAT) $(WAVES_DIR)


#############
## Sources
#############
pkg_rtl	 = $(wildcard src/pkg/*.sv)
misc_rtl = $(wildcard src/misc/rtl/*.sv)
misc_sim = $(wildcard src/misc/tb/*.sv)
alu_rtl	 = $(wildcard src/alu/rtl/*.sv)
alu_sim	 = $(wildcard src/alu/tb/*.sv)
uart_rtl = $(wildcard src/uart/rtl/*.sv)
uart_sim = $(wildcard src/uart/tb/*.sv) $(wildcard src/uart/tb/*.v)
ram_rtl	 = $(wildcard src/ram/rtl/*.sv)
ram_sim	 = $(wildcard src/ram/tb/*.sv)
dma_rtl	 = $(wildcard src/dma/rtl/*.sv)
dma_sim	 = $(wildcard src/dma/tb/*.sv)
cpu_rtl	 = $(wildcard src/cpu/rtl/*.sv)
cpu_sim	 = $(wildcard src/cpu/tb/*.sv)
top_rtl	 = $(wildcard src/top/rtl/*.sv)
top_sim	 = $(wildcard src/top/tb/*.sv)



##############################
# All the targets
##############################
all : all_elabs all_sims

all_sims : tb_misc tb_alu tb_uart tb_ram tb_dma tb_cpu tb_top

all_elabs: misc alu uart ram dma cpu top



##############################
# TOP
##############################
tb_top : $(pkg_rtl) $(alu_rtl) $(uart_rtl) $(ram_rtl) $(dma_rtl) $(cpu_rtl) $(top_rtl) $(uart_sim) $(top_sim)
	$(COMPILE_CMD) -y$(UNISIMS_DIR)
	$(SIM_CMD)
	$(WAVES_CMD)

top : $(pkg_rtl) $(misc_rtl) $(alu_rtl) $(uart_rtl) $(ram_rtl) $(dma_rtl) $(cpu_rtl) $(top_rtl) $(uart_sim)
	$(COMPILE_CMD) -y$(UNISIMS_DIR)



##############################
# CPU
##############################
tb_cpu : $(pkg_rtl) $(cpu_rtl) $(cpu_sim)
	$(COMPILE_CMD)
	$(SIM_CMD)
	$(WAVES_CMD)

cpu : $(pkg_rtl) $(cpu_rtl)
	$(COMPILE_CMD)
	$(LINT_CMD) --top-module $@



##############################
# DMA
##############################
tb_dma : $(pkg_rtl) $(dma_rtl) $(dma_sim) $(uart_rtl) $(uart_sim)
	$(COMPILE_CMD) -y$(UNISIMS_DIR)
	$(SIM_CMD)
	$(WAVES_CMD)

dma : $(pkg_rtl) $(dma_rtl)
	$(COMPILE_CMD)
	$(LINT_CMD) --top-module $@



##############################
# RAM
##############################
tb_ram : $(pkg_rtl) $(misc_rtl) $(ram_rtl) $(ram_sim)
	$(COMPILE_CMD) -y$(UNISIMS_DIR)
	$(SIM_CMD)
	$(WAVES_CMD)

ram : $(pkg_rtl) $(misc_rtl) $(ram_rtl)
	$(COMPILE_CMD)
	$(LINT_CMD) --top-module $@



####################################################
# UART (no lint as Verilator has issues with Unisim)
####################################################
tb_uart : $(pkg_rtl) $(uart_rtl) $(uart_sim)
	$(COMPILE_CMD) -y$(UNISIMS_DIR)
	$(SIM_CMD)
	$(WAVES_CMD)

uart : $(pkg_rtl) $(uart_rtl) $(uart_sim)
	$(COMPILE_CMD) -y$(UNISIMS_DIR)


##############################
# ALU
##############################
tb_alu : $(pkg_rtl) $(alu_rtl) $(alu_sim)
	$(COMPILE_CMD)
	$(SIM_CMD)
	$(WAVES_CMD)

alu : $(pkg_rtl) $(alu_rtl)
	$(LINT_CMD) --top-module $@
	$(COMPILE_CMD)


##############################
# MISC
##############################
tb_misc : $(misc_rtl) $(misc_sim)
	$(COMPILE_CMD)
	$(SIM_CMD)
	$(WAVES_CMD)

misc : $(misc_rtl)
	$(LINT_CMD) --top-module bin2bcd
	$(COMPILE_CMD)


##############################
# Global Package
##############################
global_pkg : $(pkg_rtl)


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
