
`timescale 1ns / 1ps

module data_mem(
  input wire clk, // Clock
  input wire mem_en, // Overall data memory enable
  input wire mem_we, // Data memory write enable
  input wire mem_se, // Load data sign extension enable
  input wire [1:0] mem_bs, // Data memory byte select
  input wire [31:0] addr, // Data address selector
  input wire [31:0] data_in, // Data input bus
  output wire [31:0] data_out, // Data output bus

  // Connections to physical board components
  input wire [15:0] sw_in,
  output wire [15:0] led_out
);

  reg [31:0] ram [1023:0]; // Data memory
  reg [31:0] reg_id [2:0]; // Identity registers
  reg [31:0] reg_sw, reg_led; // I/O registers

  wire main_en; // Enable main memory block based on address
  wire spec_en; // Enable special registers based on address
  reg [31:0] main_load; // Output from main ram block
  reg [31:0] spec_load; // Output from special registers
  wire [31:0] data_load; // Overall output
  wire [31:0] data_store; // Input buffer
  wire [3:0] byte_en; // Enable per byte within word
  wire [1:0] byte_addr; // Address for specific byte within each word
  wire [29:0] word_addr; // Address for word


  initial begin
    // Set identity registers with N numbers
    reg_id[0] = 32'b110110011010110000001000; // D'Arcy
    reg_id[1] = 32'b101010011110001001111110; // Irving
    reg_id[2] = 32'b101111101100101010010111; // Jayeon
    // Initialize LEDs to off
    reg_led = 32'b0;
  end

  // Subdivide total address
  assign byte_addr = addr[1:0];
  assign word_addr = addr[11:2];

  // If addr starts with 0x800, load/store main memory block
  assign main_en = (mem_en && addr[31:20] == 12'b100000000000) ? 1 :
                   (!mem_en && addr[31:20] == 12'b100000000000) ? 0 :
                   0;

  // If addr starts with 0x001, load/store special registers
  assign spec_en = (mem_en && addr[31:20] == 12'b000000000001) ? 1 :
                   (!mem_en && addr[31:20] == 12'b000000000001) ? 0 :
                   0;

  

  // Determine which bytes should be stored/loaded based on byte-select signal
  // and memory address, and arrange them accordingly
  assign byte_en = (mem_bs == 2'b11) ? 4'b1111 :
              (mem_bs == 2'b10 && byte_addr == 2'b10) ? 4'b1100 :
              (mem_bs == 2'b10 && byte_addr == 2'b00) ? 4'b0011 :
              (mem_bs == 2'b01 && byte_addr == 2'b11) ? 4'b1000 :
              (mem_bs == 2'b01 && byte_addr == 2'b10) ? 4'b0100 :
              (mem_bs == 2'b01 && byte_addr == 2'b01) ? 4'b0010 :
              (mem_bs == 2'b01 && byte_addr == 2'b00) ? 4'b0001 :
              4'bx;
  assign data_store = (byte_en == 4'b1111) ? data_in :
                      (byte_en == 4'b1100) ? {data_in[15:0], 16'bx} :
                      (byte_en == 4'b0011) ? {16'bx, data_in[15:0]} :
                      (byte_en == 4'b1000) ? {data_in[7:0], 24'bx} :
                      (byte_en == 4'b0100) ? {8'bx, data_in[7:0], 16'bx} :
                      (byte_en == 4'b0010) ? {16'bx, data_in[7:0], 8'bx} :
                      (byte_en == 4'b0001) ? {24'bx, data_in[7:0]} :
                      32'bx;

  // Synchronously load/store main memory block
  always @(posedge clk) begin

    if (main_en) begin

      if (mem_we && byte_en[3]) ram[word_addr][31:24] <= data_store[31:24];
      if (mem_we && byte_en[2]) ram[word_addr][23:16] <= data_store[23:16];
      if (mem_we && byte_en[1]) ram[word_addr][15:8] <= data_store[15:8];
      if (mem_we && byte_en[0]) ram[word_addr][7:0] <= data_store[7:0];

      main_load <= ram[word_addr];
    end
  end

  // Synchronously load/store special registers
  always @(posedge clk) begin

    if (spec_en) begin

      // Store to LED register. All other special registers are read only
      if (word_addr[2:0] == 3'b101) begin
        if (mem_we && byte_en[3]) reg_led[31:24] <= data_store[31:24];
        if (mem_we && byte_en[2]) reg_led[23:16] <= data_store[23:16];
        if (mem_we && byte_en[1]) reg_led[15:8] <= data_store[15:8];
        if (mem_we && byte_en[0]) reg_led[7:0] <= data_store[7:0];
      end

      // Load from appropriate special register
      case(word_addr[2:0])
        3'b000: spec_load <= reg_id[0];
        3'b001: spec_load <= reg_id[1];
        3'b010: spec_load <= reg_id[2];
        3'b100: spec_load <= reg_sw;
        3'b101: spec_load <= reg_led;
      endcase

      // Independent of loads/stores, update reg_sw to switch values
      reg_sw[15:0] <= sw_in; 

    end
  end

  // Select correct output
  assign data_load = (main_en) ? main_load :
                     spec_load;

  // Sign/zero extension for loads
  assign data_out = (byte_en == 4'b1111) ? data_load :
                    (mem_se && byte_en == 4'b1100) ? {{16{data_load[31]}}, data_load[31:16]} :
                    (mem_se && byte_en == 4'b0011) ? {{16{data_load[15]}}, data_load[15:0]} :
                    (mem_se && byte_en == 4'b1000) ? {{24{data_load[31]}}, data_load[31:24]} :
                    (mem_se && byte_en == 4'b0100) ? {{24{data_load[23]}}, data_load[23:16]} :
                    (mem_se && byte_en == 4'b0010) ? {{24{data_load[15]}}, data_load[15:8]} :
                    (mem_se && byte_en == 4'b0001) ? {{24{data_load[7]}}, data_load[7:0]} :
                    (!mem_se && byte_en == 4'b1100) ? {16'b0, data_load[31:16]} :
                    (!mem_se && byte_en == 4'b0011) ? {16'b0, data_load[15:0]} :
                    (!mem_se && byte_en == 4'b1000) ? {24'b0, data_load[31:24]} :
                    (!mem_se && byte_en == 4'b0100) ? {24'b0, data_load[23:16]} :
                    (!mem_se && byte_en == 4'b0010) ? {24'b0, data_load[15:8]} :
                    (!mem_se && byte_en == 4'b0001) ? {24'b0, data_load[7:0]} :
                    32'bx;

  assign led_out = reg_led[15:0];

endmodule
