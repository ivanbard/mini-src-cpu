`timescale 1ns/10ps
 
module control_unit (
    input  wire        clk,
    input  wire        reset,
    input  wire        stop,
    input  wire        con,
    input  wire [31:0] IR,
    input  wire [31:0] MDR, 
 
    output reg  [4:0]  bus_sel,
    output reg         pc_in,
    output reg         IncPC,
    output reg         ir_in,
    output reg         y_in,
    output reg         mar_in,
    output reg         hi_in,
    output reg         lo_in,
    output reg         MDRin,
    output reg         Read,
    output reg         ram_in,
    output reg  [4:0]  alu_op,
    output reg         Zin,
    output reg         Gra, Grb, Grc,
    output reg         Rin, Rout, BAout, Cout,
    output reg         con_en,
    output reg         inport_in,
    output reg         outport_in,
    output reg         jal_r12_in, 
    output reg         run
);
 
    // operation codes
    localparam [4:0]
        OP_ADD   = 5'b00000, OP_SUB   = 5'b00001,
        OP_AND   = 5'b00010, OP_OR    = 5'b00011,
        OP_SHR   = 5'b00100, OP_SHRA  = 5'b00101,
        OP_SHL   = 5'b00110, OP_ROR   = 5'b00111, OP_ROL  = 5'b01000,
        OP_ADDI  = 5'b01001, OP_ANDI  = 5'b01010, OP_ORI  = 5'b01011,
        OP_DIV   = 5'b01100, OP_MUL   = 5'b01101,
        OP_NEG   = 5'b01110, OP_NOT   = 5'b01111,
        OP_LD    = 5'b10000, OP_LDI   = 5'b10001, OP_ST   = 5'b10010,
        OP_JAL   = 5'b10011, OP_JR    = 5'b10100, OP_BR   = 5'b10101,
        OP_IN    = 5'b10110, OP_OUT   = 5'b10111,
        OP_MFHI  = 5'b11000, OP_MFLO  = 5'b11001,
        OP_NOP   = 5'b11010, OP_HALT  = 5'b11011;
 
    // find operation code with safety in case ir not set yet
    wire [4:0] opcode = (state == S_FETCH2) ? MDR[31:27] : IR[31:27];
 
    // alu codes
    localparam [4:0]
        ALU_ADD  = 5'd0,  ALU_SUB  = 5'd1,
        ALU_MUL  = 5'd2,  ALU_DIV  = 5'd3,
        ALU_AND  = 5'd4,  ALU_OR   = 5'd5,
        ALU_NOT  = 5'd6,  ALU_NEG  = 5'd7,
        ALU_SHR  = 5'd8,  ALU_SHRA = 5'd9,
        ALU_SHL  = 5'd10, ALU_ROR  = 5'd11, ALU_ROL = 5'd12;
 
    // bus selection
    localparam [4:0]
        BUS_HI  = 5'd16, BUS_LO  = 5'd17,
        BUS_ZH  = 5'd18, BUS_ZL  = 5'd19,
        BUS_PC  = 5'd20, BUS_MDR = 5'd21,
        BUS_IN  = 5'd22, BUS_C   = 5'd23;
 
    // all fsm states
    localparam [5:0]
        S_RESET   = 6'd0,
        S_FETCH0  = 6'd1,
        S_FETCH1  = 6'd2,
        S_FETCH2  = 6'd3,
        S_ALU3_T3 = 6'd4,  S_ALU3_T4 = 6'd5,  S_ALU3_T5 = 6'd6,
        S_ALU2_T3 = 6'd7,  S_ALU2_T4 = 6'd8,
        S_MUL_T3  = 6'd9,  S_MUL_T4  = 6'd10, S_MUL_T5  = 6'd11, S_MUL_T6 = 6'd12,
        S_DIV_T3  = 6'd13, S_DIV_T4  = 6'd14, S_DIV_T5  = 6'd15, S_DIV_T6 = 6'd16,
        S_LD_T3   = 6'd17, S_LD_T4   = 6'd18, S_LD_T5   = 6'd19,
        S_LD_T6   = 6'd20, S_LD_T7   = 6'd21,
        S_LDI_T3  = 6'd22, S_LDI_T4  = 6'd23, S_LDI_T5  = 6'd24,
        S_ST_T3   = 6'd25, S_ST_T4   = 6'd26, S_ST_T5   = 6'd27,
        S_ST_T6   = 6'd28, S_ST_T7   = 6'd29,
        S_IMM_T3  = 6'd30, S_IMM_T4  = 6'd31, S_IMM_T5  = 6'd32,
        S_BR_T3   = 6'd33, S_BR_T4   = 6'd34, S_BR_T5   = 6'd35, S_BR_T6  = 6'd36,
        S_JR_T3   = 6'd37,
        S_JAL_T3  = 6'd38, S_JAL_T4  = 6'd39,
        S_MFHI_T3 = 6'd40, S_MFLO_T3 = 6'd41,
        S_IN_T3   = 6'd42, S_IN_T4   = 6'd43,
        S_OUT_T3  = 6'd44,
        S_NOP_T3  = 6'd45,
        S_HALT    = 6'd46;
 
    reg [5:0] state;
    reg [5:0] next_state;
 
    // state register
    always @(posedge clk or posedge reset) begin
        if (reset) state <= S_RESET;
        else       state <= next_state;
    end
 
    // next state selection
    always @* begin
        next_state = S_FETCH0;
        if (stop) begin
            next_state = S_HALT;
        end else begin
            case (state)
                S_RESET:  next_state = S_FETCH0;
                S_FETCH0: next_state = S_FETCH1;
                S_FETCH1: next_state = S_FETCH2;
 
                S_FETCH2: begin
                case (opcode)
                    OP_ADD, OP_SUB, OP_AND, OP_OR,
                    OP_SHR, OP_SHRA, OP_SHL,
                    OP_ROR, OP_ROL:     next_state = S_ALU3_T3;
                    OP_NEG, OP_NOT:     next_state = S_ALU2_T3;
                    OP_MUL:             next_state = S_MUL_T3;
                    OP_DIV:             next_state = S_DIV_T3;
                    OP_LD:              next_state = S_LD_T3;
                    OP_LDI:             next_state = S_LDI_T3;
                    OP_ST:              next_state = S_ST_T3;
                    OP_ADDI,
                    OP_ANDI,
                    OP_ORI:             next_state = S_IMM_T3;
                    OP_BR:              next_state = S_BR_T3;
                    OP_JR:              next_state = S_JR_T3;
                    OP_JAL:             next_state = S_JAL_T3;
                    OP_MFHI:            next_state = S_MFHI_T3;
                    OP_MFLO:            next_state = S_MFLO_T3;
                    OP_IN:              next_state = S_IN_T3;
                    OP_OUT:             next_state = S_OUT_T3;
                    OP_NOP:             next_state = S_NOP_T3;
                    OP_HALT:            next_state = S_HALT;
                    default:            next_state = S_FETCH0;
                endcase
                end 
 
                S_ALU3_T3: next_state = S_ALU3_T4;
                S_ALU3_T4: next_state = S_ALU3_T5;
                S_ALU3_T5: next_state = S_FETCH0;
 
                S_ALU2_T3: next_state = S_ALU2_T4;
                S_ALU2_T4: next_state = S_FETCH0;
 
                S_MUL_T3:  next_state = S_MUL_T4;
                S_MUL_T4:  next_state = S_MUL_T5;
                S_MUL_T5:  next_state = S_MUL_T6;
                S_MUL_T6:  next_state = S_FETCH0;
 
                S_DIV_T3:  next_state = S_DIV_T4;
                S_DIV_T4:  next_state = S_DIV_T5;
                S_DIV_T5:  next_state = S_DIV_T6;
                S_DIV_T6:  next_state = S_FETCH0;
 
                S_LD_T3:   next_state = S_LD_T4;
                S_LD_T4:   next_state = S_LD_T5;
                S_LD_T5:   next_state = S_LD_T6;
                S_LD_T6:   next_state = S_LD_T7;
                S_LD_T7:   next_state = S_FETCH0;
 
                S_LDI_T3:  next_state = S_LDI_T4;
                S_LDI_T4:  next_state = S_LDI_T5;
                S_LDI_T5:  next_state = S_FETCH0;
 
                S_ST_T3:   next_state = S_ST_T4;
                S_ST_T4:   next_state = S_ST_T5;
                S_ST_T5:   next_state = S_ST_T6;
                S_ST_T6:   next_state = S_ST_T7;
                S_ST_T7:   next_state = S_FETCH0;
 
                S_IMM_T3:  next_state = S_IMM_T4;
                S_IMM_T4:  next_state = S_IMM_T5;
                S_IMM_T5:  next_state = S_FETCH0;
 
                S_BR_T3:   next_state = S_BR_T4;
                S_BR_T4:   next_state = S_BR_T5;
                S_BR_T5:   next_state = S_BR_T6;
                S_BR_T6:   next_state = S_FETCH0;
 
                S_JR_T3:   next_state = S_FETCH0;
 
                S_JAL_T3:  next_state = S_JAL_T4;
                S_JAL_T4:  next_state = S_FETCH0;
 
                S_MFHI_T3: next_state = S_FETCH0;
                S_MFLO_T3: next_state = S_FETCH0;
 
                S_IN_T3:   next_state = S_IN_T4;
                S_IN_T4:   next_state = S_FETCH0;
 
                S_OUT_T3:  next_state = S_FETCH0;
                S_NOP_T3:  next_state = S_FETCH0;
                S_HALT:    next_state = S_HALT;
                default:   next_state = S_FETCH0;
            endcase
        end
    end
 
    // control signal output based on state
    initial $display("[CU] MDR_decode_fix_v3: correct file loaded, same cycle count");
 
    always @* begin
        bus_sel    = 5'd0;
        pc_in      = 0; IncPC      = 0; ir_in      = 0;
        y_in       = 0; mar_in     = 0;
        hi_in      = 0; lo_in      = 0;
        MDRin      = 0; Read       = 0; ram_in     = 0;
        alu_op     = ALU_ADD;
        Zin        = 0;
        Gra        = 0; Grb        = 0; Grc        = 0;
        Rin        = 0; Rout       = 0;
        BAout      = 0; Cout       = 0;
        con_en     = 0;
        inport_in  = 0; outport_in = 0;
        jal_r12_in = 0;
        run        = (state != S_HALT);
 
        case (state)
            // standard states prior to each instruction
            S_FETCH0: begin 
                bus_sel = BUS_PC;
                mar_in  = 1;
                IncPC   = 1;
            end
            S_FETCH1: begin  
                Read   = 1;
                MDRin  = 1;
                ram_in = 1;
            end
            S_FETCH2: begin  
                bus_sel = BUS_MDR;
                ir_in   = 1;
            end
 
            // add, sub, and, or, shr/a, shl, ror, rol
            S_ALU3_T3: begin
                Grb  = 1; Rout = 1; y_in = 1;
            end
            S_ALU3_T4: begin
                Grc  = 1; Rout = 1;
                case (opcode)
                    OP_ADD:  alu_op = ALU_ADD;
                    OP_SUB:  alu_op = ALU_SUB;
                    OP_AND:  alu_op = ALU_AND;
                    OP_OR:   alu_op = ALU_OR;
                    OP_SHR:  alu_op = ALU_SHR;
                    OP_SHRA: alu_op = ALU_SHRA;
                    OP_SHL:  alu_op = ALU_SHL;
                    OP_ROR:  alu_op = ALU_ROR;
                    OP_ROL:  alu_op = ALU_ROL;
                    default: alu_op = ALU_ADD;
                endcase
                Zin  = 1;
            end
            S_ALU3_T5: begin
                bus_sel = BUS_ZL; Gra = 1; Rin = 1;
            end
 
            // neg, not
            S_ALU2_T3: begin
                Grb  = 1; Rout = 1;
                alu_op = (opcode == OP_NEG) ? ALU_NEG : ALU_NOT;
                Zin  = 1;
            end
            S_ALU2_T4: begin
                bus_sel = BUS_ZL; Gra = 1; Rin = 1;
            end
 
            // mul
            S_MUL_T3: begin Gra = 1; Rout = 1; y_in = 1; end
            S_MUL_T4: begin Grb = 1; Rout = 1; alu_op = ALU_MUL; Zin = 1; end
            S_MUL_T5: begin bus_sel = BUS_ZL; lo_in = 1; end
            S_MUL_T6: begin bus_sel = BUS_ZH; hi_in = 1; end
 
            // div
            S_DIV_T3: begin Gra = 1; Rout = 1; y_in = 1; end
            S_DIV_T4: begin Grb = 1; Rout = 1; alu_op = ALU_DIV; Zin = 1; end
            S_DIV_T5: begin bus_sel = BUS_ZL; lo_in = 1; end
            S_DIV_T6: begin bus_sel = BUS_ZH; hi_in = 1; end
 
            // ld
            S_LD_T3: begin Grb = 1; BAout = 1; Rout = 1; y_in = 1; end
            S_LD_T4: begin Cout = 1; bus_sel = BUS_C; alu_op = ALU_ADD; Zin = 1; end
            S_LD_T5: begin bus_sel = BUS_ZL; mar_in = 1; end
            S_LD_T6: begin Read = 1; MDRin = 1; ram_in = 1; end
            S_LD_T7: begin bus_sel = BUS_MDR; Gra = 1; Rin = 1; end
 
            // ldi
            S_LDI_T3: begin Grb = 1; BAout = 1; Rout = 1; y_in = 1; end
            S_LDI_T4: begin Cout = 1; bus_sel = BUS_C; alu_op = ALU_ADD; Zin = 1; end
            S_LDI_T5: begin bus_sel = BUS_ZL; Gra = 1; Rin = 1; end
 
            // st
            S_ST_T3: begin Grb = 1; BAout = 1; Rout = 1; y_in = 1; end
            S_ST_T4: begin Cout = 1; bus_sel = BUS_C; alu_op = ALU_ADD; Zin = 1; end
            S_ST_T5: begin bus_sel = BUS_ZL; mar_in = 1; end
            S_ST_T6: begin Gra = 1; Rout = 1; MDRin = 1; end
            S_ST_T7: begin bus_sel = BUS_MDR; ram_in = 1; end
 
            // andi, addi, ori
            S_IMM_T3: begin Grb = 1; Rout = 1; y_in = 1; end
            S_IMM_T4: begin
                Cout = 1; bus_sel = BUS_C;
                case (opcode)
                    OP_ADDI: alu_op = ALU_ADD;
                    OP_ANDI: alu_op = ALU_AND;
                    OP_ORI:  alu_op = ALU_OR;
                    default: alu_op = ALU_ADD;
                endcase
                Zin = 1;
            end
            S_IMM_T5: begin bus_sel = BUS_ZL; Gra = 1; Rin = 1; end
 
            // branching
            S_BR_T3: begin Gra = 1; Rout = 1; con_en = 1; end
            S_BR_T4: begin bus_sel = BUS_PC; y_in = 1; end
            S_BR_T5: begin Cout = 1; bus_sel = BUS_C; alu_op = ALU_ADD; Zin = 1; end
            S_BR_T6: begin bus_sel = BUS_ZL; pc_in = con; end
 
            // jr
            S_JR_T3: begin Gra = 1; Rout = 1; pc_in = 1; end
 
            // jal
            S_JAL_T3: begin bus_sel = BUS_PC; jal_r12_in = 1; end
            S_JAL_T4: begin Gra = 1; Rout = 1; pc_in = 1; end
 
            // -mfhi, mflo
            S_MFHI_T3: begin bus_sel = BUS_HI; Gra = 1; Rin = 1; end
            S_MFLO_T3: begin bus_sel = BUS_LO; Gra = 1; Rin = 1; end
 
            // in
            S_IN_T3: begin inport_in = 1; end
            S_IN_T4: begin bus_sel = BUS_IN; Gra = 1; Rin = 1; end
 
            // out
            S_OUT_T3: begin Gra = 1; Rout = 1; outport_in = 1; end
 
            // nop, reset, halt
            S_NOP_T3:  ;
            S_RESET:   ;
            S_HALT:    ;
 
        endcase
    end
 
endmodule