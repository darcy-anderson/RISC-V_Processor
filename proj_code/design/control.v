`timescale 1ns / 1ps
`include "const.v"
//////////////////////////////////////////////////////////////////////////////////


module control(
    input wire clk,
    input wire [31:0] inst,
    input wire branchValid, // for branch equals operations
    input wire control_enable,
    output reg branchEn, // 0 for PC+4, 1 for new val; to be sent to PC mux to determine jump
    output reg [2:0] immExtCtrl, // 000-I, 001-S, 010-B, 011-U, 100-J
    output reg [2:0] branchCompareOp,
    output reg aluS1Sel, // 0 for pc, 1 for reg1
    output reg aluS2Sel, // 0 for reg2, 1 for imm
    output reg [3:0] aluOp, // ALU opcode
    output reg mem_we, // 0 for not writing to data, 1 for writing to data
    output reg mem_se, // 0 for zero extension, 1 for sign extension
    output reg [1:0] mem_bs, // selecting memory bus
    output reg regWriteEn,
    output reg [1:0] regWriteBackDataSel, // 00-J, 01-I/load, 10-I/ALU, 11-U
    output reg halt_flag
    //output reg linkRegWriteEn
    );
    
    wire[6:0] instOpcode = inst[6:0];
    wire[2:0] funct3 = inst[14:12];
    wire[6:0] funct7 = inst[31:25];

    always @ (clk, inst) begin
    if (control_enable) begin
    case (instOpcode) 
        `OP_LUI: begin 
            branchEn <= 1'b0; // not branching  
            immExtCtrl <= 3'b011; // U-type
            regWriteEn <= 1'b1; // write to rd
            regWriteBackDataSel <= 2'b11; // U-type write back
        end
        
        `OP_AUIPC: begin
            branchEn <= 1'b0; // not branching
            immExtCtrl <= 3'b011; // U-type
            aluS1Sel <= 1'b0; // select PC
            aluS2Sel <=1 'b1; // select immediate
            aluOp <= `EXE_ADD_OP; // do addition
            regWriteEn <= 1'b1; // write to rd
            regWriteBackDataSel <= 2'b10; // ALU write back
        end
        
        `OP_JAL: begin
            branchEn <= 1'b1; // do arithmetic on pc  
            immExtCtrl <= 3'b100; // J-type immediate extension
            regWriteEn <= 1'b1; // write to rd
            aluS1Sel <= 1'b0; // select PC
            aluS2Sel <= 1'b1; // select immediate
            aluOp <= `EXE_ADD_OP;
            regWriteBackDataSel <= 2'b00; // J-type write back
          end
          
        `OP_JALR: begin
            branchEn <= 1'b1; // do arithmetic on pc  
            immExtCtrl <= 3'b000; // I-type immediate extension
            regWriteEn <= 1'b1; // write to rd
            aluS1Sel <= 1'b1; // select r1
            aluS2Sel <= 1'b1; // select immediate
            aluOp <= `EXE_ADD_OP;
            regWriteBackDataSel <= 2'b00; // J-type write back
        end
        
        `OP_BRANCH: begin // Missing - IMM value sent to sign extension module for pc counter handling
            case(funct3)
                `FUNCT3_BEQ : begin
                    branchCompareOp <= `EXE_BEQ_OP;
                end
                `FUNCT3_BNE : begin
                    branchCompareOp <= `EXE_BNE_OP;
                end
                `FUNCT3_BLT : begin
                    branchCompareOp <= `EXE_BLT_OP;
                end
                `FUNCT3_BGE : begin
                    branchCompareOp <= `EXE_BGE_OP;
                end 
                `FUNCT3_BLTU : begin
                    branchCompareOp <= `EXE_BLTU_OP;
                end
                `FUNCT3_BGEU : begin
                    branchCompareOp <= `EXE_BGEU_OP;
                end
            endcase
            immExtCtrl <= 3'b010; // B type immediate
            aluS1Sel <= 1'b0; // select PC
            aluS2Sel <= 1'b1; // select immediate
            aluOp <= `EXE_ADD_OP;
            regWriteEn <= 1'b0; // will not write to Reg
            regWriteBackDataSel <= 2'b00; // this doesn't matter since we are not writing anything to Reg
            if (branchValid) begin
                branchEn <= 1'b1; // change pc   
            end
        end
        
        `OP_LOAD: begin
            case(funct3) 
                `FUNCT3_LB : begin
                    mem_we <= 1'b0;
                    mem_se <= 1'b1;
                    mem_bs <= 2'b01;
                end
                `FUNCT3_LH : begin
                    mem_we <= 1'b0;
                    mem_se <= 1'b1;
                    mem_bs <= 2'b10;
                end
                `FUNCT3_LW : begin
                    mem_we <= 1'b0;
                    mem_bs <=2'b11;
                end
                `FUNCT3_LBU : begin
                    mem_we <= 1'b0;
                    mem_se <= 1'b0;
                    mem_bs <= 2'b01;
                end 
                `FUNCT3_LHU : begin
                    mem_we <= 1'b0;
                    mem_se <= 1'b0;
                    mem_bs <= 2'b10;
                end
            endcase
            branchEn <= 1'b0; // do not branch
            immExtCtrl <= 3'b000; // I-type immediate extension
            aluS1Sel <= 1'b1; // select reg 1
            aluS2Sel <= 1'b1; // select immediate
            aluOp <= `EXE_ADD_OP;
            regWriteEn <= 1'b1; // write to rd
            regWriteBackDataSel <= 2'b01; // I type load write back
        end
        
        `OP_STORE: begin            
        case(funct3) 
                `FUNCT3_SB : begin
                    mem_we <= 1'b1;
                    mem_bs <= 2'b01;                    
                end
                `FUNCT3_SH : begin
                    mem_we <= 1'b1;
                    mem_bs <= 2'b10;   
                end
                `FUNCT3_SW : begin
                    mem_we <= 1'b1;
                    mem_bs <= 2'b11;   
                end
            endcase
            branchEn <= 1'b0; // do not branch
            immExtCtrl <= 3'b001; // S-type immediate extension
            aluS1Sel <= 1'b1; // select reg 1
            aluS2Sel <= 1'b1; // select immediate
            aluOp <= `EXE_ADD_OP;
            regWriteEn <= 1'b0; // do not write to Reg
        end        
        
        `OP_ALU: begin
            case(funct3)
                `FUNCT3_ADD_SUB : begin // sub == add negative value
                    case(funct7)
                        `FUNCT7_ADD: aluOp <= `EXE_ADD_OP;
                        `FUNCT7_SUB: aluOp <= `EXE_SUB_OP;
                    endcase
                end
                `FUNCT3_SLL : begin
                    aluOp <= `EXE_SLL_OP;
                end
                `FUNCT3_SLT : begin
                    aluOp <= `EXE_SLT_OP;
                end
                `FUNCT3_SLTU : begin
                    aluOp <= `EXE_SLTU_OP;
                end 
                `FUNCT3_XOR : begin
                    aluOp <= `EXE_XOR_OP;
                end
                `FUNCT3_SRL_SRA : begin
                    case(funct7)
                        `FUNCT7_SRL: aluOp <= `EXE_SRL_OP;
                        `FUNCT7_SRA: aluOp <= `EXE_SRA_OP;
                    endcase
                end 
                `FUNCT3_OR : begin
                    aluOp <= `EXE_OR_OP;
                end
                `FUNCT3_AND : begin
                    aluOp <= `EXE_AND_OP;
                end
            endcase
            branchEn <= 1'b0; // not branching
            aluS1Sel <= 1'b1; // select reg 1
            aluS2Sel <= 1'b0; // select reg 2
            regWriteEn <= 1'b1; // write to Reg file
            regWriteBackDataSel <= 2'b10; // ALU write back
        end        
        
        `OP_ALU_IMM: begin
            case(funct3)
                `FUNCT3_ADDI : begin // sub == add negative value
                    aluOp <=`EXE_ADD_OP;
                end
                `FUNCT3_SLTI : begin
                    aluOp <= `EXE_SLT_OP;
                end
                `FUNCT3_SLTIU : begin
                    aluOp <= `EXE_SLTU_OP;
                end 
                `FUNCT3_XORI : begin
                    aluOp <= `EXE_XOR_OP;
                end
                `FUNCT3_ORI : begin
                    aluOp <= `EXE_OR_OP;
                end
                `FUNCT3_ANDI : begin
                    aluOp <= `EXE_AND_OP;
                end
                `FUNCT3_SLLI : begin
                    aluOp <= `EXE_SLL_OP;
                end
                `FUNCT3_SRL_SRA : begin
                    case(funct7)
                        `FUNCT7_SRL: aluOp <= `EXE_SRL_OP;
                        `FUNCT7_SRA: aluOp <= `EXE_SRA_OP;
                    endcase
                end 
            endcase
            branchEn <= 1'b0; // not branching
            immExtCtrl <= 3'b000; // I-type immediate
            aluS1Sel <= 1'b1; // select reg 1
            aluS2Sel <= 1'b1; // select imm
            regWriteEn <= 1'b1; // write to Reg
            regWriteBackDataSel <= 2'b10; // ALU write back
        end
        
        `OP_FENCE: begin
            branchEn <= 1'b0; // not branching
            mem_we <= 1'b0; // not writing any data
            regWriteEn <= 1'b0; // not writing to reg 
            // so basically we do nothing here.
        end

        `OP_ECALL_EBREAK: begin
            branchEn <= 1'b0; // not branching
            mem_we <= 1'b0; // not writing any data
            regWriteEn <= 1'b0; // not writing to reg 
            // so basically we do nothing here.
            halt_flag <= 1'b1; // force a halt.
        end
        
        default: begin
            branchEn <= 1'b0;
        end
    endcase
    
    end
    else begin
        branchEn = 1'b0;
    end
    end
endmodule