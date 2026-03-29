# Phase 4 Board Checklist

## Before the Lab
1. Open `cpu_fpga.qpf` in Quartus.
2. Confirm the top-level entity is `cpu_fpga`.
3. Compile once before going to the board if Quartus is available.
4. Keep `memory_p4.hex` unchanged for the official demo.

## Board Connections
1. `KEY0` is reset.
2. `KEY1` is stop.
3. `LEDR5` is the run indicator.
4. `SW[7:0]` feed the lower 8 bits of `In.Port`.
5. `HEX1:HEX0` display `Out.Port[7:4] : Out.Port[3:0]`.

## Initial Board Setup
1. Set `SW[7:0] = 0xE0`.
2. Start with `SW[9:8] = 00`.
3. Program the FPGA.
4. Press `KEY0` to reset and start the CPU.

## What You Should See
1. `LEDR5` stays high while the CPU is running.
2. `HEX1:HEX0` should display:
   `E0`, `70`, `38`, `1C`, `0E`, `07`, `03`, `01`
3. That sequence should repeat 5 times.
4. The final displayed value should be `63`.
5. After the final `halt`, `LEDR5` should go low.

## If the Display Is Too Fast or Too Slow
1. Change `SW[9:8]` and reset again with `KEY0`.
2. Suggested order:
   `00`, then `01`, then `10`, then `11`

## If Something Looks Wrong
1. First confirm `SW[7:0]` are still `E0`.
2. Press `KEY0` and re-run from reset.
3. If needed, press `KEY1` to stop the CPU.
4. Fall back to the Phase 4 smoke simulation command:

```powershell
vvp cpu_tb_p4.out +delay_hex=00000010 +quiet +nodump
```
