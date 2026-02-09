# Phase 1 Demo Checklist

## Before Demo Day

### Team Preparation
- [ ] **ALL group members MUST be present** (no exceptions)
- [ ] This is your **ONLY demo** - no partial demos allowed
- [ ] Prepare waveforms in advance (have copies ready to speed up demo)
- [ ] Know what's working, what's not working, and any outstanding issues
- [ ] Demo will take approximately **20-25 minutes**

### Instructions to Prepare
You will be asked to demo **4-5 instructions** live, including:
- [ ] **MUL** - using Booth Algorithm with Bit-Pair Recoding OR Carry Save Addition
- [ ] **Adder/Subtractor**
- [ ] **Divider** - using non-restoring division algorithm
- [ ] **Other instructions** (and, or, neg, not, shifts, rotates)

### What TAs Will Check

#### Code Review
- [ ] Verilog/VHDL code for each instruction
- [ ] Individual explanations of how you designed each unit
- [ ] Design decisions (CLAs, algorithms used, library components, etc.)
- [ ] Register numbers and contents
- [ ] Bus operation
- [ ] Opcode patterns (must match CPU Specification document)

#### Waveforms Requirements
Must include these **control signals**:
- R0in, R0out; R1in, R1out; ...; R15in, R15out
- HIin, HIout
- LOin, LOout
- PCin, PCout
- IRin
- Zin
- Zhighout, Zlowout
- Yin
- MARin
- MDRin, MDRout
- Read
- Mdatain[31..0]

Must include these **register outputs**:
- R0, R1, ..., R15
- HI, LO
- IR
- BusMuxOut
- Z

#### Timing Verification
- [ ] Correctness of register transfers in each clock cycle
- [ ] Timing matches control sequences from Lab Phase 1 document
- [ ] If your design differs, clearly explain the differences

## What to Demonstrate

### Live Demo
Prepare to execute and explain:
1. **MUL instruction** - demonstrate Booth Algorithm implementation
2. **DIV instruction** - show division working
3. **ADD/SUB instructions** - arithmetic operations
4. **Logic operations** - AND, OR, NEG, NOT
5. **Shift/Rotate operations** - SHR, SHRA, SHL, ROR, ROL

For each instruction, be ready to show:
- Register transfers at each clock cycle
- Correct control signal timing
- Bus operations
- Final results in correct registers

### What to Discuss
- [ ] Design approach for each unit
- [ ] Algorithms implemented (Booth, bit-pair recoding, etc.)
- [ ] Any differences from the standard design
- [ ] Outstanding issues or bugs
- [ ] Bonus features implemented

## Report Submission

### Timing
- [ ] Submit **AFTER** demo (not before)
- [ ] Deadline: **11:59pm on day of demo**
- [ ] Report must comply with what you demoed

### Format
- [ ] PDF format only
- [ ] One report per group
- [ ] Submit on onQ
- [ ] See Section 4 of Lab Phase 1 document for contents

### Required Statement
Include this academic integrity statement:

> "We do hereby verify that this written lab report is our own work and contains our own original ideas, concepts, and designs. No portion of this report has been copied in whole or in part from another source, with the possible exception of properly referenced material."

## Marking Breakdown (Total: 35 marks)

| Component | Marks |
|-----------|-------|
| Bus | 4 |
| Registers | 2 |
| MDR | 2 |
| MAR, IR, HI/LO, PC | 2 |
| Y, Z, and ALU circuitry | 2 |
| **Infrastructure Subtotal** | **12** |
| MUL instruction | 8 |
| DIV instruction | 5 |
| ADD/SUB instructions | 4 |
| AND/OR/NEG/NOT instructions | 3 |
| SHR/SHRA/SHL/ROR/ROL instructions | 3 |
| **Total Phase 1** | **35** |

### Penalties & Bonuses
- Late penalties: 25% (first period), 40% (second period)
- Bonus marks (up to 5) determined after final report submission

## Key Reminders

⚠️ **Critical Rules:**
- All team members must attend
- Only ONE demo per phase
- Cannot submit report before demo
- Report must match what you demoed
- No demo = no marks

✅ **Success Tips:**
- Have waveforms pre-generated and ready
- Each member should know their portion thoroughly
- Test all instructions before demo day
- Document any known issues
- Be clear about what works and what doesn't
