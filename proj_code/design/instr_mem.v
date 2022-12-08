`timescale 1ns / 1ps

module instr_mem(
	input clk, // Clock
  input imem_en, // Instruction memory read enable
  input [31:0] pc_addr, // Input address from program counter
  output [31:0] instr_out // Instruction output bus
);

  reg [31:0] instr_rom [511:0];
  reg [31:0] instr_read; // Output register

  initial $readmemh("main.mem", instr_rom);

	always @(posedge clk) begin
    if (imem_en) instr_read = instr_rom[pc_addr[12:2]];
  end

  assign instr_out = instr_read;

endmodule
