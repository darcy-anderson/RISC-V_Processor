`timescale 1ns / 1ps
`default_nettype none

module cpu_testbench();
reg clk_t, reset_t;
reg [15:0] switch_t;
wire [15:0] led_t;

cpu cpu(.clk(clk_t), .rst(reset_t), .sw(switch_t), .led(led_t));

initial begin 
clk_t=0;
forever #10 clk_t=~clk_t;
end
    
initial begin : testing
reset_t=1;
$readmemh("LS_test_mem.mem", cpu.im.instr_rom);

#100;
reset_t=0;
#400;
// testing lw/sw, x1 should be 123
// store the value of x8 to address 0x80000000, and load it to x1
// addi x8, x0, 123
// lui x9, -524288
// sw x8, 0(x9)
// lw x1, 0(x9)

if (register_file.registers[1] != 32'd123) begin
    $display("something wrong with lw/sw");
    $stop;
end
$display("lw/sw working");

#400;
// testing lw/sw, X3 should be 123
//addi x7, x0, 532
//sh x7, 0(x9)
//lh x3, 0(x9)
if (register_file.registers[3] != 32'd532) begin
    $display("something wrong with lh/sh");
    $stop;
end
$display("lh/sh working");
end
endmodule