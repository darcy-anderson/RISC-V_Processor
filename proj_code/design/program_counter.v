`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////


module program_counter(
    input wire clk,
    input wire rst,
    input wire [31:0] c_in,
    output wire [31:0] c_out
    );
reg [31:0] i_out;
always @(posedge clk)
begin
    if (rst == 1)
        i_out <= 32'h01000000;
    else 
        i_out <= c_in;
end

assign c_out = i_out;
endmodule
