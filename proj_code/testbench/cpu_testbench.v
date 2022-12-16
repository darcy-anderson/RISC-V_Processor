`timescale 1ns / 1ps
`default_nettype none

module cpu_testbench();
reg clk_t, reset_t;
reg [15:0] led_t, switch_t;

cpu cpu(.clk(clk_t), .rst(reset_t), .sw(switch_t), .led(led_t));

initial begin 
clk_t=0;
forever #20 clk_t=~clk_t;
end
    
    initial begin : testing
        
        $readmemh("LS_test_mem.mem", cpu.im.instr_rom);

        
       
        
        
        $display("\nAll test Passed\n");
        //$finish;
    end
endmodule