// TODO: Implement read/write for identity and I/O registers. Update constraints
// file to reflect I/O registers.

`timescale 1ns / 1ps

module data_mem(
  input clk, // Clock
  input mem_en, // Overall data memory enable
  input mem_we, // Data memory write enable
  input mem_se, // Load data sign extension enable
  input [1:0] mem_bs, // Data memory byte select
  input [31:0] addr, // Data address selector
  input [31:0] data_in, // Data input bus
  output [31:0] data_out // Data output bus
);

  reg [31:0] ram [1023:0];
  reg [31:0] reg_id [2:0]; // Identity registers
  reg [31:0] reg_sw, reg_led; // I/O registers
  reg [31:0] data_load; // Output data register
  wire [3:0] en; // Enable per_block
  wire [31:0] data_store;
  wire [1:0] byte_addr;
  wire [29:0] word_addr;

  initial begin
    // Set identity registers with N numbers
    reg_id[0] = 32'b110110011010110000001000; // D'Arcy
    reg_id[1] = 32'b101010011110001001111110; // Irving
    reg_id[2] = 32'b101111101100101010010111; // Jayeon
    // Initialize LEDs to off
    reg_led = 32'b0;
  end

  assign byte_addr = addr[1:0];
  assign word_addr = addr[11:2];

  // Determine which bytes should be stored/loaded based on byte-select signal
  // and memory address
  assign en = (mem_bs == 2'b11) ? 4'b1111 :
              (mem_bs == 2'b10 && byte_addr == 2'b10) ? 4'b1100 :
              (mem_bs == 2'b10 && byte_addr == 2'b00) ? 4'b0011 :
              (mem_bs == 2'b01 && byte_addr == 2'b11) ? 4'b1000 :
              (mem_bs == 2'b01 && byte_addr == 2'b10) ? 4'b0100 :
              (mem_bs == 2'b01 && byte_addr == 2'b01) ? 4'b0010 :
              (mem_bs == 2'b01 && byte_addr == 2'b00) ? 4'b0001 :
              4'bx;
  assign data_store = (en == 4'b1111) ? data_in :
                      (en == 4'b1100) ? {data_in[15:0], 16'bx} :
                      (en == 4'b0011) ? {16'bx, data_in[15:0]} :
                      (en == 4'b1000) ? {data_in[7:0], 24'bx} :
                      (en == 4'b0100) ? {8'bx, data_in[7:0], 16'bx} :
                      (en == 4'b0010) ? {16'bx, data_in[7:0], 8'bx} :
                      (en == 4'b0001) ? {24'bx, data_in[7:0]} :
                      32'bx;

  // Synchronously read/write memory
  always @(posedge clk) begin

    if (mem_en) begin

      if (mem_we && en[3]) ram[word_addr][31:24] <= data_store[31:24];
      if (mem_we && en[2]) ram[word_addr][23:16] <= data_store[23:16];
      if (mem_we && en[1]) ram[word_addr][15:8] <= data_store[15:8];
      if (mem_we && en[0]) ram[word_addr][7:0] <= data_store[7:0];

      data_load <= ram[word_addr];
    end
  end

  // Sign/zero extension for loads
  assign data_out = (en == 4'b1111) ? data_load :
                    (mem_se && en == 4'b1100) ? {{16{data_load[31]}}, data_load[31:16]} :
                    (mem_se && en == 4'b0011) ? {{16{data_load[15]}}, data_load[15:0]} :
                    (mem_se && en == 4'b1000) ? {{24{data_load[31]}}, data_load[31:24]} :
                    (mem_se && en == 4'b0100) ? {{24{data_load[23]}}, data_load[23:16]} :
                    (mem_se && en == 4'b0010) ? {{24{data_load[15]}}, data_load[15:8]} :
                    (mem_se && en == 4'b0001) ? {{24{data_load[7]}}, data_load[7:0]} :
                    (!mem_se && en == 4'b1100) ? {16'b0, data_load[31:16]} :
                    (!mem_se && en == 4'b0011) ? {16'b0, data_load[15:0]} :
                    (!mem_se && en == 4'b1000) ? {24'b0, data_load[31:24]} :
                    (!mem_se && en == 4'b0100) ? {24'b0, data_load[23:16]} :
                    (!mem_se && en == 4'b0010) ? {24'b0, data_load[15:8]} :
                    (!mem_se && en == 4'b0001) ? {24'b0, data_load[7:0]} :
                    32'bx;                                   

endmodule

