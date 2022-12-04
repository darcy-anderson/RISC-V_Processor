`timescale 1ns / 1ps

module testbench_instr_mem();

  reg t_clk = 0;
  reg t_imem_en = 0;
  reg [31:0] t_pc_addr;
  wire [31:0] t_instr_out;
  integer fp, r;
  reg [31:0] f_pc_addr;
  reg [31:0] f_instr_out;

  instr_mem dut(
    .clk(t_clk),
    .imem_en(t_imem_en),
    .pc_addr(t_pc_addr),
    .instr_out(t_instr_out)
  );

  always #5 t_clk = ~t_clk;

  initial begin
    
    // Test that no read is performed with !constraint_mode
    t_pc_addr = 32'h01000000;
		wait (t_clk == 1);
		wait (t_clk == 0);
		if (t_instr_out == 32'h24396A5E) begin
			$display("Test failed. Output is not correct at time %t.", $time);
			$stop;
    end
    
    // Test reads
    t_imem_en = 1;
    fp = $fopen("tc_instr_mem.csv", "r");
    if (fp == 0) begin
        $display("Error opening file.");
        $stop;
    end

    while (!$feof(fp)) begin
      r = $fscanf(fp, "%h,%h", f_pc_addr, f_instr_out);

      t_pc_addr = f_pc_addr;
      wait (t_clk == 1);
      wait (t_clk == 0);

      if (t_instr_out != f_instr_out) begin
        $display("Test failed. Output is not correct at time %t.", $time);
        $stop;
      end
    end

    $fclose(fp);
    $display("All tests passed. Testbench concluded.");
    $stop;  
  end
endmodule