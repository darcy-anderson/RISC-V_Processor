`timescale 1ns / 1ps
`default_nettype none
`include "const.v"
//////////////////////////////////////////////////////////////////////////////////



module BranchCompare(
    input wire [31:0] rs1,
    input wire [31:0] rs2,
    input wire [2:0] opcode,
    output wire out
    );
    
reg result;

always@(*) begin
    case(opcode)
        `EXE_BEQ_OP:
            result <= (rs1==rs2) ? 1 : 0;
        `EXE_BNE_OP:
            result <= (rs1==rs2) ? 0 : 1;
        `EXE_BLT_OP:
            result <= ($signed(rs1) < $signed(rs2)) ? 1 : 0;
        `EXE_BGE_OP:
            result <= ($signed(rs1) < $signed(rs2)) ? 0 : 1;
        `EXE_BLTU_OP:
            result <= (rs1 < rs2)? 1 : 0;
        `EXE_BGEU_OP:
            result <= (rs1 < rs2)? 0 : 1;
         default:
            result <= result;
    endcase
end

assign out = result;
endmodule
