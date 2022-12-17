`timescale 1ns / 1ps
`default_nettype none

module cpu_testbench();
reg clk_t, reset_t;
reg [15:0] switch_t;
wire [15:0] led_t;
integer fp, r;
reg f_out;

cpu cpu(.clk(clk_t), .rst(reset_t), .sw(switch_t), .led(led_t));

initial begin 
clk_t=0;
forever #10 clk_t=~clk_t;
end
    
initial begin : testing
reset_t=1;

// Test Loand and Store
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


#300;
// testing lw/sw, X3 should be 532 (1000010100)
//addi x7, x0, 532 
//sh x7, 0(x9)
//lh x3, 0(x9)
if (register_file.registers[3] != 32'd532) begin
    $display("something wrong with lh/sh");
    $stop;
end

// testing lb/lh/lbu/sb, x4 should be -1
// x28 should be 1011111111
// x29 should be 0xff
// x30 should be 0xffff
//addi x11, x0, -1 
//sb x11, 0(x9)
//lb x4, 0(x9)
//lh x28, 0(x9)
//lbu x29, 0(x9)
//sw x11, 0(x9)
//lhu x30, 0(x9)
#700;
if (register_file.registers[4] != 32'hffffffff) begin
    $display("something wrong with lb/sb");
    $stop;
end
if (register_file.registers[28] != 32'b1011111111) begin
    $display("something wrong with lh/sb");
    $stop;
end
if (register_file.registers[29] != 32'hff) begin
    $display("something wrong with lbu/sb");
    $stop;
end
if (register_file.registers[30] != 32'hffff) begin
    $display("something wrong with lhu/sb");
    $stop;
end
$display("lb/lh/lbu/lhu/sb working");
$display("All Load and Store working");

#10;


// Test Branch and Jump
//addi x1, x0, 1
//addi x2, x0, 1
//addi x3, x0, 2
//beq x1, x2, 8
//garbage
//bne x1, x3, 8
//garbage
//blt x1, x3, 8
//garbage,
//bge x3, x1, 8
//garbage,
//bltu x1, x3, 8
//garbage,
//bgeu x3, x1, 8
//garbage
//jal x4, 8
//garbage
//jalr x5, x1, 8


reset_t = 1;
$readmemh("Branch_test_mem.mem", cpu.im.instr_rom);

#100;
reset_t =0;
#500; //wait for writing to complete
if (cpu.pc.i_out != 32'h01000014) begin
    $display("something wrong with beq");
    $stop;
end
#100
if (cpu.pc.i_out != 32'h0100001c) begin
    $display("something wrong with bne");
    $stop;
end
#100
if (cpu.pc.i_out != 32'h01000024) begin
    $display("something wrong with blt");
    $stop;
end
#100
if (cpu.pc.i_out != 32'h0100002c) begin
    $display("something wrong with bge");
    $stop;
end
#100
if (cpu.pc.i_out != 32'h01000034) begin
    $display("something wrong with bltu");
    $stop;
end
#100
if (cpu.pc.i_out != 32'h0100003c) begin
    $display("something wrong with bgeu");
    $stop;
end
#100
if ( (cpu.pc.i_out != 32'h01000044) || (register_file.registers[4] != 32'h01000040)) begin
    $display("something wrong with jal");
    $stop;
end
#100
if ( (cpu.pc.i_out != 32'h9) || (register_file.registers[5] != 32'h01000048)) begin
    $display("something wrong with jalr");
    $stop;
end
#100
$display("All Branch and Jump working");


// Test LUI, AUIPC, ECALL
//lui x9, -524288
//auipc x8, -524288
//ecall

reset_t = 1;
$readmemh("U_Ecall_test_mem.mem", cpu.im.instr_rom);

#100;
reset_t =0;
#200; //wait for writing to complete
if ((register_file.registers[9] != 32'h80000000)) begin
    $display("something wrong with lui");
    $stop;
end
#100;
if ((register_file.registers[8] != 32'h81000004)) begin
    $display("something wrong with auipc");
    $stop;
end
#100;
if ((cpu.state_curr != 3'b111)) begin
    $display("something wrong with ecall");
    $stop;
end

$display("LUI, AUIPC, ECALL working");


// Test fence, ebreak
// fence
// ebreak
reset_t = 1;
$readmemh("fence_ebreak_test_mem.mem", cpu.im.instr_rom);

#100;
reset_t =0;
#200;
if ((cpu.state_curr != 3'b111)) begin
    $display("something wrong with ebreak");
    $stop;
end

$display("FENCE, EBREAK working");

// Test arithmetic
reset_t = 1;
$readmemh("arith_test.mem", cpu.im.instr_rom);

#100;
reset_t = 0;

fp = $fopen("tc_arith.csv", "r");
if (fp == 0) begin
    $display("Error opening file.");
    $stop;
end

while (!$feof(fp)) begin
    r = $fscanf(fp, "%h", f_out);
    #100
    if ((register_file.registers[12] != f_out)) begin
        $display("something wrong with arithmetic");
        $stop;
    end
end
 
$fclose(fp);

$display("EVERY INDIVIDUAL INSTRUCTION WORKING!!!!");
$stop;

end


endmodule