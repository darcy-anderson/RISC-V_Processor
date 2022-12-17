`timescale 1ns / 1ps

module imm_ext(
  input wire [2:0] imm_opcode, // 000-I, 001-S, 010-B, 011-U, 100-J
  input wire [31:0] inst, // Non extended input value
  output wire [31:0] imm_out // Extended output value
);
    reg [31:0] imm_reg;
    wire [11:0] imm_i;
    wire [11:0] imm_s; 
    wire [12:1] imm_b;
    wire [31:12] imm_u;
    wire [20:1] imm_j;
    

    assign imm_i = inst[31:20];
    assign imm_b = {inst[31], inst[7], inst[30:25], inst[11:8]};
    assign imm_s = {inst[31:25], inst[11:7]};
    assign imm_u = inst[31:12];
    assign imm_j = {inst[31],inst[19:12], inst[20], inst[30:21]};
    
    always@(*) begin
   
        case (imm_opcode)
            3'b000: begin // I-type
                if(imm_i[11]==1)
                    imm_reg <= {20'b11111111111111111111, imm_i[11:0]};
                else
                    imm_reg <= {20'b00000000000000000000, imm_i[11:0]};
            end
            
            3'b001: begin //S-type
                if(imm_s[11]==1)
                    imm_reg <= {20'b11111111111111111111, imm_s[11:0]};
                else
                    imm_reg <= {20'b00000000000000000000, imm_s[11:0]};
            end
            
            3'b010: begin // B-TYPE     
                if (imm_b[12]==1)
                    imm_reg <= {19'b1111111111111111111, imm_b[12:1], 1'b0};
                else
                    imm_reg <= {19'b0000000000000000000, imm_b[12:1], 1'b0};
            end

            3'd011: begin //U-type
                imm_reg <= {imm_u[31:12], 12'b000000000000};
            end
            
            3'd100: begin //J-type
                if (imm_j[20] ==1)
                    imm_reg <= {11'b11111111111, imm_j[20:1], 1'b0};
                else
                    imm_reg <= {11'b00000000000 , imm_j[20:1], 1'b0};
            end
            
            default:
                imm_reg <= 0;
        endcase
    end

    assign imm_out = imm_reg;
endmodule