`timescale 1ns / 1ps
`default_nettype none
`include "const.v"
//////////////////////////////////////////////////////////////////////////////////



module ALU(
    input wire [31:0] operand1,
    input wire [31:0] operand2,                
    input wire [3:0] opcode,
    output wire [31:0] out
    );
    
reg [31:0] result;
wire [9:0] funct;
//assign funct = {funct7, funct3};

always @(*) begin // I don't really want to use always, but it seesm like if I want to use case I have to
    case (opcode)
        `EXE_ADD_OP: //ADD
            result <= operand1 + operand2;
//        10'b0100000000: //SUB
//            result <= operand1 - operand2;
//        10'b0000000001: //SLL
//            result <= operand1 << operand2[4:0];
//        10'b0000000010: //SLT
//            result <= ($signed(operand1) < $signed(operand2)) ? 1 : 0;
//        10'b0000000011: //SLTU
//            result <= (operand1 < operand2) ? 1 : 0;
//        10'b0000000100: //XOR
//            result <= operand1 ^ operand2;
//        10'b0000000101: //SRL
//            result <= operand1 >> operand2[4:0];
//        10'b0100000101: //SRA
//            result <= $signed(operand1) >>> operand2[4:0];
//        10'b0000000110: //OR
//            result <= operand1 | operand2;
//        10'b0000000111: //AND
//            result <= operand1 & operand2;
        default:    
            result <= result;
    endcase        
end

assign out = result;
endmodule
