`timescale 1ns / 1ps
`default_nettype none

module cpu_testbench();
reg clk_t, reset_t;
reg [15:0] switch_t;
wire [15:0] led_t;

cpu cpu(.clk(clk_t), .rst(reset_t), .sw(switch_t), .led(led_t));

initial begin 
clk_t=0;
forever #20 clk_t=~clk_t;
end
    
initial begin : testing
    reset_t=1;
    $readmemh("LS_test_mem.mem", cpu.im.instr_rom);
//switch = 15'd0;
//led = 15'd0;
    #100;
    reset_t=0;
    

    //$display("\nAll test Passed\n");
    //$finish;
end
endmodule