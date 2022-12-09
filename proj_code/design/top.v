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

initial
begin
    clk = 0;
    reset = 1;
end

always #10 clk = ~ clk;

cpu processor(.clk(clk), .rst(reset));

endmodule
