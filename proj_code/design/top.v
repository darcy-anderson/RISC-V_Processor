`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


module top(
// include machine clk input later
    );

reg clk, reset;
reg [15:0] switch_t;
wire [15:0] led_t;

cpu cpu(.clk(clk), .rst(reset), .sw(switch_t), .led(led_t));

initial begin 
clk=0;
forever #20 clk=~clk;
end

initial begin
reset=1;
//switch = 15'd0;
//led = 15'd0;
#100;
reset=0;
end

endmodule
