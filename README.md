# CPU Design Project
Verilog implementation of the Mini SRC CPU, simulated with Icarus Verilog and viewed in GTKWave.

# Current Status
Phase 3 is implemented in the RTL under `project/rtl` and exercised by the full-program testbench in `project/simulation/P3/cpu_tb.v`.

The control unit is implemented in the Method 1 style from the assignment:
- A finite-state machine selects the next micro-state from the current state and opcode.
- Control signals are asserted directly per state.
- The design is centered around explicit fetch/execute states, not Boolean equations for each control line.

# Phase 3 Coverage
Implemented in the CPU datapath/control integration:
- Fetch sequence and instruction decode
- `nop` and `halt`
- Register-register ALU ops
- Immediate ALU ops
- `ld`, `ldi`, `st`
- `mul`, `div`, `mfhi`, `mflo`
- `jr`, `jal`
- Branch condition evaluation through `con_ff`

Verified assets in the repo:
- Single-instruction Phase 1 and Phase 2 testbenches in `project/simulation/P1` and `project/simulation/P2`
- Full Phase 3 program image in `project/simulation/P3/memory_p3.hex`
- Full Phase 3 end-to-end testbench in `project/simulation/P3/cpu_tb.v`
- GTKWave save file for Phase 3 in `project/output/P3/cpu_tb.gtkw`

# Running Phase 3
From `project/`:

```powershell
iverilog -o cpu_tb.out -f project.f simulation/P3/cpu_tb.v
vvp cpu_tb.out
gtkwave cpu_tb.vcd output/P3/cpu_tb.gtkw
```

The Phase 3 testbench generates:
- `cpu_tb.vcd`
- `memory_before.hex`
- `memory_after.hex`

# Report Checklist
For the Phase 3 submission, include:
- Verilog source for the control unit and integrated datapath
- Functional simulation run of the Phase 3 program
- Waveform screenshots showing `IR`, `PC`, `MDR`, `MAR`, `R0-R15`, `HI`, and `LO`
- Memory contents before the run from `memory_before.hex`
- Memory contents after the run from `memory_after.hex`

# Notes
- The RAM module currently loads `simulation/P3/memory_p3.hex` by default.
- The multiplier still compiles with width warnings in `project/rtl/booth_multiplier.v`, but the Phase 3 functional test passes end-to-end.
