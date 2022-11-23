`timescale 1ns / 1ps
`include "const.v"
//////////////////////////////////////////////////////////////////////////////////
// TODO: overall need consideration on how to do immediate value handling 
// 1. sign extension to ALU for load and store addresses
// 2. sign extension to PC for jump or branch
// 3. ALU for immediate operations (add immediate)
//
// additionally, could be preferable to have separate control units for different components?
//////////////////////////////////////////////////////////////////////////////////


module control(
    input clk,
    input [31:0] inst,
    input aluEq, // for branch equals operations
    output reg regWrite,
    output reg memRead, // TODO: modify to 2 bits for word/half/byte access
    output reg memWrite, // TODO: modify to 2 bits
    output reg memToReg, // 0 for ALU result, 1 for mem data
    output reg aluSrc, // 0 for reg data, 1 for imm
    output reg [3:0] aluOp, // usually generated from 
    output reg branch // 0 for PC+4, 1 for new val; to be sent to PC mux to determine jump
    );
    
    wire[6:0] instOpcode = inst[6:0];
    wire[2:0] funct3 = inst[14:12];
    wire[6:0] funct7 = inst[31:25];

    always @ (clk, inst) begin
    
    case (instOpcode) 
        `OP_LUI: begin 
            regWrite = 1'b0;
            memRead = 1'b0;
            memWrite = 1'b0;
            memToReg = 1'b0;
            aluSrc = 1'b1;
            aluOp = `EXE_ADD_OP; // add upper immediate 
            branch = 1'b0;        
        end
        `OP_AUIPC: begin
            regWrite = 1'b0;
            memRead = 1'b0;
            memWrite = 1'b0;
            memToReg = 1'b0;
            aluSrc = 1'b1;
            aluOp = `EXE_ADD_OP;
            branch = 1'b1; // change pc     
        end
        `OP_JAL: begin
            regWrite = 1'b0;
            memRead = 1'b0;
            memWrite = 1'b0;
            memToReg = 1'b0;
            aluSrc = 1'b0;
            aluOp = `EXE_JAL_OP;
            branch = 1'b1; // change pc     
        end
        `OP_JALR: begin
            regWrite = 1'b0;
            memRead = 1'b0;
            memWrite = 1'b0;
            memToReg = 1'b0;
            aluSrc = 1'b0;
            aluOp = `EXE_JALR_OP;
            branch = 1'b1; // change pc     
        end
        `OP_BRANCH: begin // Missing - IMM value sent to sign extension module for pc counter handling
            case(funct3)
                `FUNCT3_BEQ : begin
                    aluOp = `EXE_BEQ_OP;
                end
                `FUNCT3_BNE : begin
                    aluOp = `EXE_BNE_OP;
                end
                `FUNCT3_BLT : begin
                    aluOp = `EXE_BLT_OP;
                end
                `FUNCT3_BGE : begin
                    aluOp = `EXE_BGE_OP;
                end 
                `FUNCT3_BLTU : begin
                    aluOp = `EXE_BLTU_OP;
                end
                `FUNCT3_BGEU : begin
                    aluOp = `EXE_BGEU_OP;
                end
            endcase
            aluSrc = 1'b0;
            regWrite = 1'b0;
            memRead = 1'b0;
            memWrite = 1'b0;
            memToReg = 1'b0;
            branch = 1'b1; // change pc   
        end
        `OP_LOAD: begin // TODO: info handling for sign extension module, and 
            case(funct3) 
                `FUNCT3_LB : begin
                    aluOp = `EXE_LB_OP;
                end
                `FUNCT3_LH : begin
                    aluOp = `EXE_LH_OP;
                end
                `FUNCT3_LW : begin
                    aluOp = `EXE_LW_OP;
                end
                `FUNCT3_LBU : begin
                    aluOp = `EXE_LBU_OP;
                end 
                `FUNCT3_LHU : begin
                    aluOp = `EXE_LHU_OP;
                end
            endcase
            regWrite = 1'b1;
            memRead = 1'b1; // TODO: update to 2 bits and set different values for each funct3, or add a memory control unit to mask unwanted values
            memWrite = 1'b0;
            memToReg = 1'b1;
            aluSrc = 1'b0;
            branch = 1'b0;     
        end         
        `OP_STORE: begin            
        case(funct3) 
                `FUNCT3_SB : begin
                    aluOp = `EXE_SB_OP;
                end
                `FUNCT3_SH : begin
                    aluOp = `EXE_SH_OP;
                end
                `FUNCT3_SW : begin
                    aluOp = `EXE_SW_OP;
                end
            endcase
            regWrite = 1'b0;
            memRead = 1'b0;
            memWrite = 1'b1; // TODO:
            memToReg = 1'b0;
            aluSrc = 1'b1;
            branch = 1'b0;     
        end        
        `OP_ALU: begin
        case(funct3)
                `FUNCT3_ADD_SUB : begin // sub == add negative value
                    case(funct7)
                        `FUNCT7_ADD: aluOp = `EXE_ADD_OP;
                        `FUNCT7_SUB: aluOp = `EXE_SUB_OP;
                    endcase
                end
                `FUNCT3_SLL : begin
                    aluOp = `EXE_SLL_OP;
                end
                `FUNCT3_SLT : begin
                    aluOp = `EXE_SLT_OP;
                end
                `FUNCT3_SLTU : begin
                    aluOp = `EXE_SLTU_OP;
                end 
                `FUNCT3_XOR : begin
                    aluOp = `EXE_XOR_OP;
                end
                `FUNCT3_SRL_SRA : begin
                    case(funct7)
                        `FUNCT7_SRL: aluOp = `EXE_SRL_OP;
                        `FUNCT7_SRA: aluOp = `EXE_SRA_OP;
                    endcase
                end 
                `FUNCT3_OR : begin
                    aluOp = `EXE_OR_OP;
                end
                `FUNCT3_AND : begin
                    aluOp = `EXE_AND_OP;
                end
            endcase
            regWrite = 1'b1;
            memRead = 1'b0;
            memWrite = 1'b0;
            memToReg = 1'b0;
            aluSrc = 1'b0;
            branch = 1'b0;      
        end        
        `OP_ALU_IMM: begin
        case(funct3)
                `FUNCT3_ADDI : begin // sub == add negative value
                    aluOp = `EXE_SLL_OP;
                end
                `FUNCT3_SLLI : begin
                    aluOp = `EXE_SLL_OP;
                end
                `FUNCT3_SLTI : begin
                    aluOp = `EXE_SLT_OP;
                end
                `FUNCT3_SLTIU : begin
                    aluOp = `EXE_SLTU_OP;
                end 
                `FUNCT3_XORI : begin
                    aluOp = `EXE_XOR_OP;
                end
                `FUNCT3_SRL_SRA : begin
                    case(funct7)
                        `FUNCT7_SRL: aluOp = `EXE_SRL_OP;
                        `FUNCT7_SRA: aluOp = `EXE_SRA_OP;
                    endcase
                end 
                `FUNCT3_ORI : begin
                    aluOp = `EXE_OR_OP;
                end
                `FUNCT3_ANDI : begin
                    aluOp = `EXE_AND_OP;
                end
            endcase
            regWrite = 1'b1;
            memRead = 1'b0;
            memWrite = 1'b0;
            memToReg = 1'b0;
            aluSrc = 1'b1;
            branch = 1'b0;     
        end
        default: $diplay("incorrect opcode");
    endcase
    
    end
endmodule


