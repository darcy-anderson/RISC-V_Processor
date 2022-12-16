`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////

module register_file(
    input wire clk,                          
    input wire [4:0] rd, // destination register
    input wire [4:0] r1, // first register
    input wire [4:0] r2, // second register
    input wire [31:0] write_data, // data that needs to be written
    input wire w_en, // write enable 
    input wire r_en, // read enable    
    output wire [31:0] r1_read, // to hold the data read to r1
    output wire [31:0] r2_read  // to hold the data read to r2
    );

reg [31:0] i_r1_read; 
reg [31:0] i_r2_read;

reg [31:0] registers [0:31]; // the actual register content
initial begin
registers[0] <= 32'b0;
registers[1] <= 32'b0;
registers[2] <= 32'b0;
registers[3] <= 32'b0;
registers[4] <= 32'b0;
registers[5] <= 32'b1010;
registers[6] <= 32'b0;
registers[7] <= 32'h7fffffff;
registers[8] <= 32'b0;
registers[9] <= 32'b0;
registers[10] <= 32'b0;
registers[11] <= 32'b0;
registers[12] <= 32'b0;
registers[13] <= 32'b0;
registers[14] <= 32'b0;
registers[15] <= 32'b0;
registers[16] <= 32'b0;
registers[17] <= 32'b0;
registers[18] <= 32'b0;
registers[19] <= 32'b0;
registers[20] <= 32'b0;
registers[21] <= 32'b0;
registers[22] <= 32'b0;
registers[23] <= 32'b0;
registers[24] <= 32'b0;
registers[25] <= 32'b0;
registers[26] <= 32'b0;
registers[27] <= 32'b0;
registers[28] <= 32'b0;
registers[29] <= 32'b0;
registers[30] <= 32'b0;
registers[31] <= 32'b0;
end

always @(posedge clk) begin

    if (w_en == 1) begin
        if (rd != 0)
            registers[rd] <= write_data;
        $display("writing to register %h value %h", rd, write_data); 
    end
    if (r_en == 1) begin
        if (r1 != 0)
            i_r1_read <= registers[r1];
        else
            i_r1_read <= 32'b0;
        if (r2 != 0)
            i_r2_read <= registers[r2];
        else
            i_r2_read <= 32'b0;
    end
end

assign r1_read = i_r1_read;
assign r2_read = i_r2_read;
endmodule
