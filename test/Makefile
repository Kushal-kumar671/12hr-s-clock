# Makefile for TinyTapeout 12-Hour Clock

# Default target
all: sim

# Simulation with iverilog
sim: tb.vcd
	@echo "Simulation completed. View tb.vcd with gtkwave."

tb.vcd: tb.v tt_um_clock_12h.v
	iverilog -o tb tb.v tt_um_clock_12h.v
	vvp tb
	@echo "VCD file generated: tb.vcd"

# Cocotb test
test:
	$(MAKE) -f Makefile.cocotb

# Create Makefile.cocotb for cocotb testing
Makefile.cocotb:
	@echo "# Cocotb Makefile" > Makefile.cocotb
	@echo "TOPLEVEL_LANG = verilog" >> Makefile.cocotb
	@echo "VERILOG_SOURCES = tt_um_clock_12h.v" >> Makefile.cocotb
	@echo "TOPLEVEL = tt_um_clock_12h" >> Makefile.cocotb
	@echo "MODULE = test" >> Makefile.cocotb
	@echo "include \$$(shell cocotb-config --makefiles)/Makefile.sim" >> Makefile.cocotb

# Synthesis check (requires yosys)
synth: tt_um_clock_12h.v
	yosys -p "read_verilog tt_um_clock_12h.v; synth -top tt_um_clock_12h; stat"

# Format check (requires verilator)
lint: tt_um_clock_12h.v
	verilator --lint-only --Wall tt_um_clock_12h.v

# Clean generated files
clean:
	rm -f tb tb.vcd
	rm -f *.log *.jou
	rm -rf sim_build/
	rm -f results.xml
	rm -f Makefile.cocotb

# View waveforms (requires gtkwave)
wave: tb.vcd
	gtkwave tb.vcd &

# Help
help:
	@echo "Available targets:"
	@echo "  all      - Run basic simulation (default)"
	@echo "  sim      - Run iverilog simulation"
	@echo "  test     - Run cocotb tests"
	@echo "  synth    - Run synthesis check with yosys"
	@echo "  lint     - Run lint check with verilator"
	@echo "  wave     - View waveforms with gtkwave"
	@echo "  clean    - Clean generated files"
	@echo "  help     - Show this help"

# Phony targets
.PHONY: all sim test synth lint clean wave help