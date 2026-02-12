# CPU Design Project
In Verilog, using Icarus Verilog and GTKWave

# To-Do
## Phase 2

## 1. Memory Subsystem
- [ ] Implement Memory Address Register (MAR)
- [ ] Implement Memory Data Register (MDR)
- [ ] Add MDR input mux (Bus vs Memory Data)
- [ ] Implement RAM (512 × 32)
  - [ ] Choose synchronous RAM
  - [ ] Support Read and Write signals
- [ ] Connect RAM output → MDR → Bus
- [ ] Initialize memory (e.g., $readmemh or Quartus HEX file)
- [ ] Verify correct read/write behavior

---

## 2. Select & Encode Logic
- [ ] Extract Ra, Rb, Rc fields from IR
- [ ] Implement 4-to-16 decoder
- [ ] Generate R0in–R15in signals
- [ ] Generate R0out–R15out signals
- [ ] Support Gra, Grb, Grc control signals
- [ ] Support Rin and Rout control signals
- [ ] Implement BAout behavior
  - [ ] R0 outputs 0 onto bus
  - [ ] R1–R15 output register contents

---

## 3. Sign Extension Logic
- [ ] Sign-extend IR[18:0] to 32 bits
- [ ] Fan out MSB of C field (IR[18])
- [ ] Output C_sign_extended

---

## 4. Revised R0 Register
- [ ] Modify R0 to support BAout
  - [ ] BAout = 1 → output 0
  - [ ] BAout = 0 → normal output
- [ ] Preserve write capability when R0in asserted

---

## 5. CON FF (Conditional Branch) Logic
- [ ] Decode C2 field (IR[20:19])
- [ ] Evaluate register value on bus:
  - [ ] Zero (brzr)
  - [ ] Non-zero (brnz)
  - [ ] Positive (brpl)
  - [ ] Negative (brmi)
- [ ] Generate CON signal
- [ ] Latch CON using CON flip-flop
- [ ] Support CONin enable signal

---

## 6. Input / Output Ports
- [ ] Implement Input Port register
- [ ] Implement Output Port register
- [ ] Connect ports to BusMux
- [ ] Optional: handle input strobe signal
- [ ] Verify bus ↔ port data flow

---

## 7. Functional Simulation (Instruction Testing)

### Memory Instructions
- [ ] ld
- [ ] ldi
- [ ] st

### ALU Immediate Instructions
- [ ] addi
- [ ] andi
- [ ] ori

### Branch Instructions
- [ ] brzr
- [ ] brnz
- [ ] brpl
- [ ] brmi

### Jump Instructions
- [ ] jr
- [ ] jal

### Special Instructions
- [ ] mfhi
- [ ] mflo

### I/O Instructions
- [ ] out
- [ ] in

---

## 8. Report Preparation
- [ ] Clean Verilog/VHDL code
- [ ] Testbench(s)
- [ ] Memory initialization printout
- [ ] Simulation waveforms for all Phase 2 instructions
- [ ] Brief explanation of testbench reuse
