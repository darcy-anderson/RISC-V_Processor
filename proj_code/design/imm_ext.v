`timescale 1ns / 1ps

module imm_ext(
  input wire [1:0] imm_ext_en, // Control signal
  input wire [19:0] imm_in, // Non extended input value
  output wire [31:0] imm_out // Extended output value
);

  assign imm_out = (imm_ext_en == 2'b00) ? {{20{imm_in[11]}}, imm_in[11:0]} : // Signed 12-bit
                   (imm_ext_en == 2'b01) ? {{12{imm_in[19]}}, imm_in[19:0]} : // Signed 20-bit
                   (imm_ext_en == 2'b10) ? {20'b0, imm_in[11:0]} : // Unsigned 12-bit
                   (imm_ext_en == 2'b11) ? {12'b0, imm_in[19:0]} : // Unsigned 20-bit
                   32'bx;

endmodule