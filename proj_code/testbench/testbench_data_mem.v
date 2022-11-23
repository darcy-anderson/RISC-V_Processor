`timescale 1ns / 1ps

module testbench_data_mem();

  reg t_clk = 0;
  reg [1:0] t_write_en;
  reg [31:0] t_addr;
  reg [31:0] t_data_in;
  wire [31:0] t_data_out;
  integer fp, r;
  reg [1:0] f_write_en;
  reg [31:0] f_addr;
  reg [31:0] f_data;

  data_mem dut(
    .clk(t_clk),
    .write_en(t_write_en),
    .addr(t_addr),
    .data_in(t_data_in),
    .data_out(t_data_out)
  );

  always #5 t_clk = ~t_clk;

  initial begin
    
    fp = $fopen("test_cases_data_mem.csv", "r");
    if (fp == 0) begin
        $display("Error opening file.");
        $stop;
    end

    while (!$feof(fp)) begin
      r = $fscanf(fp, "%h,%h,%h", f_write_en, f_addr, f_data);

      t_write_en = f_write_en;
      t_addr = f_addr;
      t_data_in = f_data;
      wait (t_clk == 1);
      wait (t_clk == 0);
      t_write_en = 2'b11;
      wait (t_clk == 1);
      wait (t_clk == 0);

      if (t_write_en == 2'b00) begin
        if (t_data_out != f_data) begin
          $display("Test failed. Output is not correct at time %t.", $time);
          $stop;
        end
      end
      else if (t_write_en == 2'b01) begin
        if (t_data_out[15:0] != f_data[15:0]) begin
          $display("Test failed. Output is not correct at time %t.", $time);
          $stop;
        end
      end
      else if (t_write_en == 2'b10) begin
        if (t_data_out[7:0] != f_data[7:0]) begin
          $display("Test failed. Output is not correct at time %t.", $time);
          $stop;
        end
      end
    end

    $fclose(fp);
    $display("All tests passed. Testbench concluded.");
    $stop;  
  end
endmodule


