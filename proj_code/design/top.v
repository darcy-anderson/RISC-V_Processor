`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2022 06:10:08 PM
// Design Name: 
// Module Name: top
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


module top(
// include machine clk input later
    );

reg clk, reset;

cpu processor(.clk(clk), .rst(reset));

initial begin 
clk=0;
forever #10 clk=~clk;
end

initial begin
reset=1;
#100;
reset=0;
end

endmodule
