`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2022 02:14:16 AM
// Design Name: 
// Module Name: program_counter_mux
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


module program_counter_mux(
    input wire clk,
    input wire jump_en,
    input wire [31:0] pc_increment,
    input wire [31:0] pc_jump_target,
    output wire [31:0] pc_next
    );
    
reg [31:0] next;

always @ (posedge clk)
begin
    if (jump_en)
        next <= pc_increment;
   else
        next <= pc_jump_target;
end
    
assign pc_next = next;
endmodule
