`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2022 02:28:09 AM
// Design Name: 
// Module Name: branchALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module branchALU(
    input wire [31:0] s1,
    input wire [31:0] s2,
    input wire [2:0] opcode,
    output wire branchResult
    );
    
    reg result;
    
    always @(*) begin
    case (opcode)
            default:    
            result <= 1'b0;
    endcase      
    end

    assign branchResult = result;
endmodule
