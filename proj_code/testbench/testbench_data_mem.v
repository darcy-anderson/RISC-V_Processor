`timescale 1ns / 1ps

/*
For each testcase, the given data is saved, then loaded, and the loaded data is
compared to the original data. Testcases are formatted line by line in the CSVs as:
mem_en,address,data
where mem_en controls the save operation. For the loads, mem_en is set by the
testbench itself.

First, save testcases are loaded. Depending on read mem_en, word, half-word, or byte
saves are used. Then mem_en is changed to load word, and only the relevant bits
are compared to verify test result.

Second, load testcases are loaded. Load word is not tested further, as it was
extensively used in the first part. Depending on read mem_en, half-word or byte
saves are used. The MSB of mem_en, which is not used for saves, is used to 
inform the testbench whether to use signed or unsigned loads. All bits are used
for comparison.
*/

module testbench_data_mem();

  reg t_clk = 0;
  reg t_mem_en;
  reg t_mem_we;
  reg t_mem_se;
  reg [3:0] t_mem_bs;
  reg [31:0] t_addr;
  reg [31:0] t_data_in;
  wire [31:0] t_data_out;
  integer fp, r;
  reg f_mem_se;
  reg [3:0] f_mem_bs;
  reg [31:0] f_addr;
  reg [31:0] f_data;

  data_mem dut(
    .clk(t_clk),
    .mem_en(t_mem_en),
    .mem_we(t_mem_we),
    .mem_se(t_mem_se),
    .mem_bs(t_mem_bs),
    .addr(t_addr),
    .data_in(t_data_in),
    .data_out(t_data_out)
  );

  always #5 t_clk = ~t_clk;

  initial begin
    
    // Test mem_en
    t_mem_en = 0;
    t_mem_we = 1;
    t_mem_se = 0;
    t_mem_bs = 2'b11;
    t_data_in = 32'b10101010101010101010101010101010;
    t_addr = 32'h80000000;
    wait (t_clk == 1);
    wait (t_clk == 0);
    t_mem_we = 0;
		wait (t_clk == 1);
    wait (t_clk == 0);
    if (t_data_out == t_data_in) begin
    	$display("Test failed. Output is not correct at time %t.", $time);
      $stop;
    end
    
    t_mem_en = 1;
    
    // Test stores
    fp = $fopen("tc_data_mem_save.csv", "r");
    if (fp == 0) begin
        $display("Error opening file.");
        $stop;
    end

    while (!$feof(fp)) begin
      r = $fscanf(fp, "%h,%h,%h", f_mem_bs, f_addr, f_data);

			t_mem_we = 1;
      t_mem_bs = f_mem_bs;
      t_addr = f_addr;
      t_data_in = f_data;
      wait (t_clk == 1);
      wait (t_clk == 0);
      t_mem_we = 0;
      wait (t_clk == 1);
      wait (t_clk == 0);

      // Store word
      if (t_mem_bs == 2'b11) begin
        if (t_data_out != f_data) begin
          $display("Test failed. Output is not correct at time %t.", $time);
          $stop;
        end
      end
      // Store half-word
      else if (t_mem_bs == 2'b10) begin
        if (t_data_out[15:0] != f_data[15:0]) begin
          $display("Test failed. Output is not correct at time %t.", $time);
          $stop;
        end
      end
      // Store byte
      else if (t_mem_bs == 2'b01) begin
        if (t_data_out[7:0] != f_data[7:0]) begin
          $display("Test failed. Output is not correct at time %t.", $time);
          $stop;
        end
      end
    end

    $fclose(fp);

    // Test loads
    fp = $fopen("tc_data_mem_load.csv", "r");
    if (fp == 0) begin
        $display("Error opening file.");
        $stop;
    end

    while (!$feof(fp)) begin
      r = $fscanf(fp, "%h,%h,%h,%h", f_mem_bs, f_mem_se, f_addr, f_data);

			t_mem_we = 1;
      t_mem_bs = f_mem_bs;
      t_mem_se = f_mem_se;
      t_addr = f_addr;
      t_data_in = f_data;
      wait (t_clk == 1);
      wait (t_clk == 0);
      t_mem_we = 0;
      wait (t_clk == 1);
      wait (t_clk == 0);

			if (t_data_out != f_data) begin
				$display("Test failed. Output is not correct at time %t.", $time);
				$stop;
			end   
    end

    $fclose(fp);  

    $display("All tests passed. Testbench concluded.");
    $stop;
  end
endmodule


