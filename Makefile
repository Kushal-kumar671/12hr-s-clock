# Makefile for 12hr-s-clock TinyTapeout Project

# Project configuration
PROJECT_NAME = 12hr-s-clock
TOP_MODULE = tt_um_12hr_s_clock
VERILOG_FILES = src/$(PROJECT_NAME).v
TESTBENCH = test/tb.v
PYTHON_TEST = test/test.py

# Default target
all: sim

# Basic simulation with iverilog
sim: tb.vcd
	@echo "=== Simulation completed ==="
	@echo "View waveforms with: make wave"
	@echo "Run Python tests with: make test"

# Generate VCD file for waveform viewing
tb.vcd: $(TESTBENCH) $(VERILOG_FILES)
	@echo "=== Running Verilog simulation ==="
	cd test && iverilog -o tb -I../src $(TESTBENCH) ../$(VERILOG_FILES)
	cd test && vvp tb
	@echo "VCD file generated: test/tb.vcd"

# Cocotb Python testing
test: $(VERILOG_FILES) $(PYTHON_TEST)
	@echo "=== Running Cocotb Python tests ==="
	@$(MAKE) -f Makefile.cocotb 2>/dev/null || $(MAKE) create-cocotb-makefile
	@$(MAKE) -f Makefile.cocotb

# Create Cocotb Makefile if it doesn't exist
create-cocotb-makefile:
	@echo "=== Creating Cocotb Makefile ==="
	@echo "# Auto-generated Cocotb Makefile" > Makefile.cocotb
	@echo "TOPLEVEL_LANG = verilog" >> Makefile.cocotb
	@echo "VERILOG_SOURCES = $(VERILOG_FILES)" >> Makefile.cocotb
	@echo "TOPLEVEL = $(TOP_MODULE)" >> Makefile.cocotb
	@echo "MODULE = test" >> Makefile.cocotb
	@echo "TESTCASE = " >> Makefile.cocotb
	@echo "export PYTHONPATH := test:\$$(PYTHONPATH)" >> Makefile.cocotb
	@echo "include \$$(shell cocotb-config --makefiles)/Makefile.sim" >> Makefile.cocotb

# Synthesis check (requires yosys)
synth: $(VERILOG_FILES)
	@echo "=== Running synthesis check ==="
	yosys -p "read_verilog $(VERILOG_FILES); synth -top $(TOP_MODULE); stat; check"

# Lint check (requires verilator) 
lint: $(VERILOG_FILES)
	@echo "=== Running lint check ==="
	verilator --lint-only --Wall -I./src $(VERILOG_FILES)

# Format check (basic)
format-check: $(VERILOG_FILES)
	@echo "=== Checking file format ==="
	@echo "Checking for tabs vs spaces..."
	@! grep -P '\t' $(VERILOG_FILES) || (echo "ERROR: Tabs found in Verilog files" && false)
	@echo "✓ No tabs found"
	@echo "Checking line endings..."
	@file $(VERILOG_FILES) | grep -q "CRLF" && echo "WARNING: Windows line endings found" || echo "✓ Unix line endings"

# View waveforms (requires gtkwave)
wave: test/tb.vcd
	@echo "=== Opening waveform viewer ==="
	cd test && gtkwave tb.vcd &

# Clean generated files
clean:
	@echo "=== Cleaning generated files ==="
	rm -f test/tb test/tb.vcd
	rm -f *.log *.jou *.history
	rm -rf test/sim_build/
	rm -f test/results.xml
	rm -f Makefile.cocotb
	rm -rf __pycache__/ test/__pycache__/
	rm -f *.vvp

# Deep clean (including backup files)
distclean: clean
	@echo "=== Deep cleaning ==="
	find . -name "*~" -delete
	find . -name "*.bak" -delete
	find . -name ".DS_Store" -delete

# Project validation
validate: lint format-check
	@echo "=== Validating project structure ==="
	@test -f $(VERILOG_FILES) || (echo "ERROR: Main Verilog file not found: $(VERILOG_FILES)" && false)
	@test -f $(TESTBENCH) || (echo "ERROR: Testbench not found: $(TESTBENCH)" && false)
	@test -f $(PYTHON_TEST) || (echo "ERROR: Python test not found: $(PYTHON_TEST)" && false)
	@test -f info.yaml || (echo "ERROR: info.yaml not found" && false)
	@echo "✓ All required files present"
	@grep -q "$(TOP_MODULE)" $(VERILOG_FILES) || (echo "ERROR: Top module name mismatch" && false)
	@echo "✓ Module name matches"

# Generate project statistics
stats: $(VERILOG_FILES)
	@echo "=== Project Statistics ==="
	@echo "Lines of code:"
	@wc -l $(VERILOG_FILES) $(TESTBENCH) $(PYTHON_TEST) info.yaml
	@echo ""
	@echo "Verilog module analysis:"
	@grep -c "module\|always\|assign\|wire\|reg" $(VERILOG_FILES) | sed 's/.*://' | paste -sd+ | bc | xargs echo "Total constructs:"

# Quick test (fast simulation)
quick-test: $(VERILOG_FILES) $(TESTBENCH)
	@echo "=== Quick functionality test ==="
	cd test && echo 'module quick_tb; initial begin $$display("Quick test - module compiles"); $$finish; end endmodule' > quick_tb.v
	cd test && iverilog -o quick_tb -I../src quick_tb.v ../$(VERILOG_FILES)
	cd test && vvp quick_tb
	cd test && rm -f quick_tb quick_tb.v
	@echo "✓ Module compiles successfully"

# Help target
help:
	@echo "=== 12hr-s-clock Build System ==="
	@echo ""
	@echo "Available targets:"
	@echo "  all          - Run basic simulation (default)"
	@echo "  sim          - Run Verilog simulation with iverilog"
	@echo "  test         - Run comprehensive Cocotb Python tests"
	@echo "  quick-test   - Fast compilation check"
	@echo ""
	@echo "Analysis:"
	@echo "  lint         - Run Verilator lint check"
	@echo "  synth        - Run Yosys synthesis check"
	@echo "  format-check - Check file formatting"
	@echo "  validate     - Validate project structure"
	@echo "  stats        - Show project statistics"
	@echo ""  
	@echo "Viewing:"
	@echo "  wave         - Open waveform viewer (gtkwave)"
	@echo ""
	@echo "Maintenance:"
	@echo "  clean        - Remove generated files"
	@echo "  distclean    - Deep clean including backups"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Files:"
	@echo "  Main module: $(VERILOG_FILES)"
	@echo "  Testbench:   $(TESTBENCH)"
	@echo "  Python test: $(PYTHON_TEST)"

# Phony targets (don't correspond to files)
.PHONY: all sim test quick-test create-cocotb-makefile synth lint format-check 
.PHONY: wave clean distclean validate stats help

# Default goal
.DEFAULT_GOAL := all