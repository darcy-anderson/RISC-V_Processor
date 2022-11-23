`timescale 1ns / 1ps

module data_mem(
  input clk, // Clock
  input [1:0] write_en, // Write/read enable
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
    if (write_en == 2'b00) begin
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
    else if (write_en == 2'b01) begin
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
    else if (write_en == 2'b10) begin
      case (addr[1:0])
        2'b00: begin
          ramblock0[addr[11:2]] <= data_in[7:0];
        end
        2'b01: begin
          ramblock1[addr[11:2]] <= data_in[7:0];
        end
        2'b10: begin
          ramblock2[addr[11:2]] <= data_in[7:0];
        end
        2'b11: begin
          ramblock3[addr[11:2]] <= data_in[7:0];
        end
      endcase
    end
    
    // Read word
    else begin // write_en == 2'b11
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
  end

  assign data_out = data_read;

endmodule

