IVERILOG ?= iverilog
VVP ?= vvp
IVFLAGS := -g2012 -Wall -Wno-timescale
BUILD_DIR := build

.PHONY: test test-p3 test-p4 fpga-check clean

test: test-p3 test-p4 fpga-check

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

test-p3: | $(BUILD_DIR)
	cd project && $(IVERILOG) $(IVFLAGS) -s cpu_tb -o ../$(BUILD_DIR)/cpu-p3.out -f project.f simulation/P3/cpu_tb.v
	cd project && $(VVP) ../$(BUILD_DIR)/cpu-p3.out +nodump

test-p4: | $(BUILD_DIR)
	cd project && $(IVERILOG) $(IVFLAGS) -s cpu_tb -o ../$(BUILD_DIR)/cpu-p4.out -f project.f simulation/P4/cpu_tb.v
	cd project && $(VVP) ../$(BUILD_DIR)/cpu-p4.out +delay_hex=00000010 +quiet +nodump

fpga-check: | $(BUILD_DIR)
	cd project && $(IVERILOG) $(IVFLAGS) -s cpu_fpga -o ../$(BUILD_DIR)/cpu-fpga.out -f fpga.f

clean:
	$(RM) -r $(BUILD_DIR)
