# CPU Design Project
Verilog implementation of the Mini SRC CPU, simulated with Icarus Verilog and prepared for DE0-CV FPGA bring-up.

# Current Status
Phase 3 is complete and still supported.

Phase 4 is prepared in this branch:
- The Phase 4 memory image is in `project/simulation/P4/memory_p4.hex`.
- The CPU can be instantiated with a selectable RAM init file.
- The DE0-CV top-level is in `project/rtl/cpu_fpga.v`.
- Quartus project files are in `project/cpu_fpga.qpf`, `project/cpu_fpga.qsf`, and `project/cpu_fpga.sdc`.
- The dedicated Phase 4 simulation testbench is in `project/simulation/P4/cpu_tb.v`.

# Control Unit Style
The control unit is implemented in Method 1 style from the assignment:
- A finite-state machine selects the next micro-state from the current state and opcode.
- Control signals are asserted directly per state.
- The design is organized around explicit fetch and execute states rather than derived Boolean equations per control signal.

# Running Phase 3
From `project/`:

```powershell
iverilog -o cpu_tb.out -f project.f simulation/P3/cpu_tb.v
vvp cpu_tb.out
gtkwave cpu_tb.vcd output/P3/cpu_tb.gtkw
```

# Running Phase 4 Simulation
From `project/`:

```powershell
iverilog -o cpu_tb_p4.out -f project.f simulation/P4/cpu_tb.v
vvp cpu_tb_p4.out
```

Useful Phase 4 simulation options:
- Fast smoke test:

```powershell
vvp cpu_tb_p4.out +delay_hex=00000010 +quiet +nodump
```

- Waveform view after a dumped run:

```powershell
gtkwave cpu_tb_p4.vcd output/P4/cpu_tb.gtkw
```

The Phase 4 testbench writes:
- `memory_p4_before.hex`
- `memory_p4_after.hex`

# FPGA Bring-Up
Open `project/cpu_fpga.qpf` in Quartus and use top-level `cpu_fpga`.

If you want a quick syntax build of the FPGA top-level with Icarus:

```powershell
iverilog -s cpu_fpga -o cpu_fpga_build.out -f fpga.f
```

Board mapping prepared in RTL and QSF:
- `KEY0` -> reset
- `KEY1` -> stop
- `LEDR5` -> run indicator
- `SW[7:0]` -> `In.Port[7:0]`
- `HEX1:HEX0` -> `Out.Port[7:4] : Out.Port[3:0]`
- Fixed divided CPU clock -> about 1.56 MHz

# Notes
- The dedicated FPGA top-level always boots with the Phase 4 image.
- The generic CPU module still defaults to the Phase 3 image unless overridden by parameter.
- The multiplier still compiles with width warnings in `project/rtl/booth_multiplier.v`, but the current Phase 3 and Phase 4 smoke tests pass.
- See `project/PHASE4_BOARD_CHECKLIST.md` for a short board-demo checklist.
