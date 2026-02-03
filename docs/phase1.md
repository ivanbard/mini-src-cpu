# Designing a Simple RISC Computer (Mini SRC)
## ELEC 374 – Digital Systems Engineering  
**Department of Electrical and Computer Engineering**  
**Queen’s University**  
**Winter 2026**

---

# CPU Phase 1 – Lab Project

## 1. Objectives

The objective of this project is to design, simulate, implement, and verify a simple RISC Computer (Mini SRC), consisting of a simple RISC processor, memory, and I/O.

Phase 1 of this project consists of the **design and Functional Simulation of a part of the Mini SRC datapath**. In this phase, you will design the necessary logic and simulate the following instructions:

- add  
- sub  
- mul  
- div  
- and  
- or  
- shr  
- shra  
- shl  
- ror  
- rol  
- neg  
- not  

The following components are **not** included in Phase 1 and will be addressed later:

- Select and Encode Logic  
- CON FF Logic  
- Input/Output ports  
- Memory Subsystem  
- load/store instructions  
- branch and jump instructions  
- addi, andi, ori instructions  

Instruction decoding will be done in **Phase 3**.

The complete datapath is shown in Figure 1 of the original document.

Design input can be done entirely using **Verilog or VHDL**. You may use components available in the Quartus Prime Library, **except**:

> You must design your own multiplication circuitry using either:
> - 32×32 Booth algorithm with bit-pair recoding, or  
> - Carry-Save Adders for summand addition  

You are **not allowed** to use simple arithmetic operators (`+`, `-`, etc.) in the ALU implementation, except for **multiplication and division circuitry**.

---

## 2. Preliminaries

### 2.1 Datapath

The Mini SRC datapath consists of a **32-bit single bus (BUS)** that transfers information between system components. Only one transaction may occur on the bus at a time.

The system includes:

- Sixteen 32-bit registers: R0–R15  
- Two dedicated 32-bit registers: HI and LO  
- 32-bit Instruction Register (IR)  
- 32-bit Program Counter (PC)  
- Memory Address Register (MAR)  
- Memory Data Register (MDR)  
- Temporary register Y  
- 64-bit Z register  

PC is incremented by 1 during instruction fetch using the `IncPC` signal.

The ALU has inputs **A** and **B**, and output **C**. Because the bus supports only one transaction at a time, input A must be stored in register **Y**.

The ALU supports the following operations:

- ADD, SUB  
- MUL, DIV  
- SHR, SHRA, SHL  
- ROR, ROL  
- AND, OR  
- NEG, NOT  

The **Z register** holds ALU results and is 64 bits wide to support multiplication and division results.

---

### Typical Register Behavior

A typical register (e.g., R1):

- Loads data from `BusMuxOut` on rising clock edge when `R1in` is asserted
- Places data onto the bus when `R1out` is asserted
- Includes a `Clear` signal

---

### Bus Design

The Mini SRC bus can be implemented using:

- Multiplexer/encoder approach  
- Tri-state buffers  
- Other equivalent techniques  

A common implementation uses:

- 32:1 multiplexer (BusMux)
- 32-to-5 encoder

Possible bus sources include:

- R0–R15  
- HI, LO  
- Zhigh, Zlow  
- PC  
- MDR  
- In.Port  
- Sign-extended constant C  

---

### Memory Data Register (MDR)

The MDR has:

- Two input sources:
  - Memory (`Mdatain`)
  - Internal bus (`BusMuxOut`)
- Two output destinations:
  - Memory
  - Bus  

MDR loads data on rising clock edge when `MDRin` is asserted.

---

## 3. Lab Procedure

You must design the datapath shown in Figure 1 **excluding**:

- Select and Encode Logic  
- CON FF Logic  
- Memory chip  
- Input/Output ports  

### Recommended Steps

1. Design registers:
   - R0–R15, PC, IR, Y, Z, MAR, HI, LO
2. Design and simulate the bus
3. Design the MDR and connect it to the bus
4. Design the ALU:
   - Logical units (and, or, not)
   - Add/sub circuitry
   - Multiplication (Booth or CSA)
   - Division circuitry  

---

## 3.1 Required Control and Output Signals

### Control Signals

R0in, R0out; R1in, R1out; …; R15in, R15out  
HIin, HIout  
LOin, LOout  
PCin, PCout  
IRin  
Zin  
Zhighout, Zlowout  
Yin  
MARin  
MDRin, MDRout  
Read  
Mdatain[31..0]

### Outputs

R0–R15  
HI  
LO  
IR  
BusMuxOut  
Z  

---

## 3.2 Sample Control Sequence – AND Instruction

Instruction: `and R2, R5, R6`

| Step | Control Signals |
|----|----|
| T0 | PCout, MARin, IncPC, Zin |
| T1 | Zlowout, PCin, Read, MDRin |
| T2 | MDRout, IRin |
| T3 | R5out, Yin |
| T4 | R6out, AND, Zin |
| T5 | Zlowout, R2in |

---

## 3.3 Sample Verilog Testbench (AND)

```verilog
`timescale 1ns/10ps
module datapath_tb; 
 reg PCout, Zlowout, MDRout, R5out, R6out;
 reg MARin, Zin, PCin, MDRin, IRin, Yin; 
 reg IncPC, Read, AND, R2in, R5in, R6in;
 reg Clock;
 reg [31:0] Mdatain; 
 ...
endmodule

(Code continues exactly as in original document)
3.4 Sample VHDL Testbench (AND)

LIBRARY ieee;
USE ieee.std_logic_1164.all;
ENTITY datapath_tb IS
END ENTITY datapath_tb;
...
END ARCHITECTURE datapath_tb_arch;

3.5–3.13 Instruction Demonstrations

You must demonstrate correct operation for:

    OR

    ADD

    SUB

    MUL

    DIV

    SHR

    SHRA

    SHL

    ROR

    ROL

    NEG

    NOT

Each instruction follows its specified control sequence exactly as listed in the Phase 1 document.
4. Phase 1 Report Requirements

Your Phase 1 lab report must include:

    Verilog/VHDL code

    Testbenches

    Functional simulation runs for all tests (3.1–3.13)

CPU Phase 1 Demo, Report Submission, and Marking Guidelines
Lab Demo Rules

    All group members must be present

    Only one demo per phase

    TAs will ask for live demos of 4–5 instructions

    Waveforms must be available

    Explain design choices and algorithms used

Lab Report Submission

    Submit one PDF per group

    Deadline: 11:59pm on demo day

    No demo → no marking

    Include academic integrity statement

Marking Rubric (Phase 1 – 35%)
Component	Marks
Bus	4
Registers	2
MDR	2
MAR, IR, HI/LO, PC	2
Y, Z, ALU	2
MUL	8
DIV	5
ADD/SUB	4
AND/OR/NEG/NOT	3
SHIFTS/ROTATES	3
CPU Specification – Mini SRC
Processor Overview

    32-bit datapath

    16 registers (R0–R15)

    Dedicated HI and LO registers

    No condition code register

    Memory: 512 × 32-bit words

Processor State

    PC<31..0>

    IR<31..0>

    R[0..15]<31..0>

    HI<31..0>

    LO<31..0>

Instruction Formats

    R-Format

    I-Format

    B-Format

    J-Format

    M-Format

All instructions are 32 bits long.
Instruction Set
Arithmetic and Logical

    add, sub, and, or

    shr, shra, shl

    ror, rol

    addi, andi, ori

    mul, div

    neg, not

Load / Store

    ld, ldi, st

Branch

    brzr, brnz, brmi, brpl

Jump

    jr, jal

I/O and Misc

    in, out

    mfhi, mflo

    nop, halt

Design Phases

    Phase 1 – Datapath (7%)

    Phase 2 – Memory & Branching (7%)

    Phase 3 – Control Unit (5%)

    Phase 4 – FPGA Implementation (3%)

    Final Report (3%)

Bonus Marks

Up to 5% bonus for advanced designs:

    Multi-bus architectures

    Advanced ALU techniques

    Pipelining

    Branch prediction

    Superscalar design