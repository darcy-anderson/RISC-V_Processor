`timescale 1ns / 1ps

module data_mem(
  input clk, // Clock
  input [3:0] mem_en, // Memory control signal
  input [31:0] addr, // Data address selector
  input [31:0] data_in, // Data input bus
  output [31:0] data_out // Data output bus
);

  // 4 single-byte wide interweaved memory sets
  reg [7:0] ramblock0 [1023:0];
  reg [7:0] ramblock1 [1023:0];
  reg [7:0] ramblock2 [1023:0];
  reg [7:0] ramblock3 [1023:0];

  reg [31:0] data_read;
  reg [31:0] addr_incr; // Required for accessing next row for misaligned addresses

  always @(posedge clk) begin

    addr_incr = addr + 1;

    // Save word
    if (mem_en[2:0] == 3'b111) begin
      case (addr[1:0])
        2'b00: begin
          ramblock0[addr[11:2]] <= data_in[7:0];
          ramblock1[addr[11:2]] <= data_in[15:8];
          ramblock2[addr[11:2]] <= data_in[23:16];
          ramblock3[addr[11:2]] <= data_in[31:24];
        end
        2'b01: begin
          ramblock1[addr[11:2]] <= data_in[7:0];
          ramblock2[addr[11:2]] <= data_in[15:8];
          ramblock3[addr[11:2]] <= data_in[23:16];
          ramblock0[addr_incr[11:2]] <= data_in[31:24];
        end
        2'b10: begin
          ramblock2[addr[11:2]] <= data_in[7:0];
          ramblock3[addr[11:2]] <= data_in[15:8];
          ramblock0[addr_incr[11:2]] <= data_in[23:16];
          ramblock1[addr_incr[11:2]] <= data_in[31:24];
        end
        2'b11: begin
          ramblock3[addr[11:2]] <= data_in[7:0];
          ramblock0[addr_incr[11:2]] <= data_in[15:8];
          ramblock1[addr_incr[11:2]] <= data_in[23:16];
          ramblock2[addr_incr[11:2]] <= data_in[31:24];
        end
      endcase
    end

    // Save half-word
    else if (mem_en[2:0] == 3'b110) begin
      case (addr[1:0])
        2'b00: begin
          ramblock0[addr[11:2]] <= data_in[7:0];
          ramblock1[addr[11:2]] <= data_in[15:8];
        end
        2'b01: begin
          ramblock1[addr[11:2]] <= data_in[7:0];
          ramblock2[addr[11:2]] <= data_in[15:8];
        end
        2'b10: begin
          ramblock2[addr[11:2]] <= data_in[7:0];
          ramblock3[addr[11:2]] <= data_in[15:8];
        end
        2'b11: begin
          ramblock3[addr[11:2]] <= data_in[7:0];
          ramblock0[addr_incr[11:2]] <= data_in[15:8];
        end
      endcase
    end

    // Save byte
    else if (mem_en[2:0] == 3'b101) begin
      case (addr[1:0])
        2'b00: ramblock0[addr[11:2]] <= data_in[7:0];
        2'b01: ramblock1[addr[11:2]] <= data_in[7:0];
        2'b10: ramblock2[addr[11:2]] <= data_in[7:0];
        2'b11: ramblock3[addr[11:2]] <= data_in[7:0];
      endcase
    end
    
    // Read word
    else if (mem_en[2:0] == 3'b011) begin
    	case (addr[1:0])
        2'b00: begin
          data_read[7:0] <= ramblock0[addr[11:2]];
          data_read[15:8] <= ramblock1[addr[11:2]];
          data_read[23:16] <= ramblock2[addr[11:2]];
          data_read[31:24] <= ramblock3[addr[11:2]];
        end
        2'b01: begin
          data_read[7:0] <= ramblock1[addr[11:2]];
          data_read[15:8] <= ramblock2[addr[11:2]];
          data_read[23:16] <= ramblock3[addr[11:2]];
          data_read[31:24] <= ramblock0[addr_incr[11:2]];
        end
        2'b10: begin
          data_read[7:0] <= ramblock2[addr[11:2]];
          data_read[15:8] <= ramblock3[addr[11:2]];
          data_read[23:16] <= ramblock0[addr_incr[11:2]];
          data_read[31:24] <= ramblock1[addr_incr[11:2]];
        end
        2'b11: begin
          data_read[7:0] <= ramblock3[addr[11:2]];
          data_read[15:8] <= ramblock0[addr_incr[11:2]];
          data_read[23:16] <= ramblock1[addr_incr[11:2]];
          data_read[31:24] <= ramblock2[addr_incr[11:2]];
        end
      endcase
  	end

    // Read half-word
    else if (mem_en[2:0] == 3'b010) begin
      case (addr[1:0])
        2'b00: begin
          data_read[7:0] = ramblock0[addr[11:2]];
          data_read[15:8] = ramblock1[addr[11:2]];
        end
        2'b01: begin
          data_read[7:0] = ramblock1[addr[11:2]];
          data_read[15:8] = ramblock2[addr[11:2]];
        end
        2'b10: begin
          data_read[7:0] = ramblock2[addr[11:2]];
          data_read[15:8] = ramblock3[addr[11:2]];
        end
        2'b11: begin
          data_read[7:0] = ramblock3[addr[11:2]];
          data_read[15:8] = ramblock0[addr_incr[11:2]];
        end
      endcase
      // Pad values
      if (!mem_en[3]) data_read[31:16] = 16'b0000000000000000; // Unsigned
      else begin // Sign extension 
        if (data_read[15]) data_read[31:16] = 16'b1111111111111111;
        else data_read[31:16] = 16'b0000000000000000;
      end
    end

    // Read byte
    else if (mem_en[2:0] == 3'b001) begin
      case (addr[1:0])
        2'b00: data_read[7:0] = ramblock0[addr[11:2]];
        2'b01: data_read[7:0] = ramblock1[addr[11:2]];
        2'b10: data_read[7:0] = ramblock2[addr[11:2]];
        2'b11: data_read[7:0] = ramblock3[addr[11:2]];
      endcase
      // Pad values
      if (!mem_en[3]) data_read[31:8] = 24'b000000000000000000000000; // Unsigned
      else begin // Sign extension
        if (data_read[7]) data_read[31:8] = 24'b111111111111111111111111;
        else data_read[31:8] = 24'b000000000000000000000000;
      end
    end
  end

  assign data_out = data_read;

endmodule

