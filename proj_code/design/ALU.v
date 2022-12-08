`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////



module ALU(
    input wire [31:0] operand1,
    input wire [31:0] operand2,                
    input wire [3:0] opcode,
    output wire [31:0] out
    );
    
reg [31:0] result;


always @(*) begin // I don't really want to use always, but it seesm like if I want to use case I have to
    case (opcode)
        `EXE_ADD_OP: //ADD
            result <= operand1 + operand2;
        `EXE_SUB_OP: //SUB
            result <= operand1 - operand2;
        `EXE_SLL_OP: //SLL
            result <= operand1 << operand2[4:0];
        `EXE_SLT_OP: //SLT
            result <= ($signed(operand1) < $signed(operand2)) ? 1 : 0;
        `EXE_SLTU_OP: //SLTU
            result <= (operand1 < operand2) ? 1 : 0;
        `EXE_XOR_OP: //XOR
            result <= operand1 ^ operand2;
        `EXE_SRL_OP: //SRL
            result <= operand1 >> operand2[4:0];
        `EXE_SRA_OP: //SRA
            result <= $signed(operand1) >>> operand2[4:0];
        `EXE_OR_OP: //OR
            result <= operand1 | operand2;
        `EXE_AND_OP: //AND
            result <= operand1 & operand2;
        default:    
            result <= result;
    endcase        
end

assign out = result;
endmodule
