# Design notes

## Processor overview

Mini SRC is a 32-bit multicycle processor built around one internal bus. A finite-state control unit sequences register transfers for instruction fetch, operand collection, execution, memory access, and writeback. The implementation favors explicit hardware structures so the datapath is visible in simulation rather than hidden behind behavioral operators.

| Property | Implementation |
| --- | --- |
| Instruction width | 32 bits |
| Data width | 32 bits |
| General registers | 16 (`R0`-`R15`) |
| Special registers | `PC`, `IR`, `MAR`, `MDR`, `Y`, `Z`, `HI`, `LO` |
| Memory | 512 x 32-bit words |
| Control | Multicycle finite-state machine |
| Datapath | Single 32-bit bus with a 64-bit ALU result path |

The source is split between [`control_unit.v`](../project/rtl/control_unit.v), which chooses the next micro-state and asserts control signals, and [`datapath_top.v`](../project/rtl/datapath_top.v), which connects registers, memory, the ALU, condition logic, and I/O.

## Datapath

Only one source drives the internal bus in a cycle. Register fields from the instruction are decoded into one-hot input and output selects, while a bus encoder selects special sources such as `PC`, `MDR`, `Z`, the input port, or a sign-extended constant.

The ALU receives one operand from the `Y` register and the other from the bus. Its 64-bit result is latched in `Z`; multiplication and division can then move their upper and lower halves through `HI` and `LO`.

Arithmetic structures include:

- a 32-bit ripple-carry adder reused for addition, subtraction, and negation;
- a radix-4 Booth multiplier with 17 signed partial products;
- a combinational non-restoring divider with signed input/output handling;
- a five-stage barrel shifter for logical shift, arithmetic shift, and rotation.

RAM writes are synchronous and reads are asynchronous. The memory image is selected through the `MEM_INIT_FILE` parameter, allowing the same CPU module to boot either complete test program.

## Instruction execution

Every instruction begins with three fetch states:

1. Put `PC` on the bus, load `MAR`, and calculate the incremented address.
2. Write the incremented address back to `PC` and read memory into `MDR`.
3. Transfer `MDR` into `IR` and dispatch using `IR[31:27]`.

Execute states then perform the required bus transfers. A three-register ALU instruction, for example, loads `Y`, computes into `Z`, and writes `Zlow` to the destination register. Loads and stores add address and memory states. Branches latch one of four conditions from the selected register before optionally replacing `PC`.

## Instruction set

The five-bit opcode occupies bits `[31:27]`. Register fields `Ra`, `Rb`, and `Rc` occupy `[26:23]`, `[22:19]`, and `[18:15]`; immediate instructions sign-extend the low 19 bits.

| Group | Instructions |
| --- | --- |
| Arithmetic | `add`, `sub`, `addi`, `mul`, `div`, `neg` |
| Logic | `and`, `or`, `andi`, `ori`, `not` |
| Shift and rotate | `shr`, `shra`, `shl`, `ror`, `rol` |
| Memory | `ld`, `ldi`, `st` |
| Control flow | `jal`, `jr`, `brzr`, `brnz`, `brpl`, `brmi` |
| Data movement and I/O | `in`, `out`, `mfhi`, `mflo` |
| Miscellaneous | `nop`, `halt` |

All four conditional branches share one branch opcode. Bits `[20:19]` select zero, nonzero, nonnegative, or negative comparison.

## Verification strategy

The repository retains the original component and instruction testbenches under `project/simulation/P1` and `P2`. The repeatable public gate uses the two self-checking system programs:

| Program | What it checks | Recorded result |
| --- | --- | --- |
| `P3/cpu_tb.v` | Final general registers, `HI`, `LO`, and memory | Pass, 270 total cycles |
| `P4/cpu_tb.v` | Input capture, 41-value output sequence, memory, and halt | Pass, 12,466 cycles with the delay override |

The P4 delay override changes only the program's busy-wait constant so CI completes quickly. The expected I/O and final architectural state remain checked. Both benches use fatal exits for timeouts or mismatches, so `make test` and GitHub Actions cannot treat a printed failure as a pass.

## FPGA implementation

[`cpu_fpga.v`](../project/rtl/cpu_fpga.v) divides the 50 MHz board clock to approximately 1.56 MHz, synchronizes the active-low push buttons, maps the switches to the input port, and displays the output byte on two seven-segment displays.

The last recorded Quartus Prime 25.1 Standard fit completed successfully for the DE0-CV Cyclone V `5CEBA4F23C7`:

| Resource | Usage |
| --- | --- |
| Logic utilization | 10,068 / 18,480 ALMs (54%) |
| Registers | 17,262 |
| Pins | 65 / 224 (29%) |
| Block memory | 0 bits |
| DSP blocks | 0 |

The asynchronous RAM read makes the design simple to simulate but prevents inference of the device's synchronous block RAM. Refactoring memory would also require new control timing, so it remains a documented educational tradeoff rather than a cosmetic portfolio change.

## Reproducing the FPGA demo

1. Open `project/cpu_fpga.qpf` in Quartus Prime and compile `cpu_fpga`.
2. Set `SW[7:0]` to `E0` and program the board.
3. Press `KEY0` to reset and start the CPU.
4. Confirm `LEDR5` remains lit while the CPU runs.
5. Observe `E0 70 38 1C 0E 07 03 01` five times on `HEX1:HEX0`, followed by `63` and an extinguished run LED.

`KEY1` stops execution. Until that sequence is observed on physical hardware, the repository claims simulation and synthesis success only.
