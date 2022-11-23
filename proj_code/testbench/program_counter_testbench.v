`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////



module program_counter_testbench();

reg clk_t, rst_t, rst_f;
reg [31:0] c_in_t, c_in_f;
wire [31:0] c_out_t, c_out_f;

integer file_pointer;

program_counter PC_test(
    .clk(clk_t),
    .rst(rst_t),
    .c_in(c_in_t),
    .c_out(c_out_t)
);
initial begin
    file_pointer = $fopen("PC_tcases.txt", "r");
    if (file_pointer == 0) begin
        $display ("Could not open test cases file.");
        $stop;
    end
    clk_t=0;
    while (!$feof(file_pointer)) begin
        $fscanf(file_pointer, "%b %h %h\n" , rst_f, c_in_f, c_out_f);
        
        #5; // assign test value in the middle of falling edge2
        rst_t = rst_f;
        c_in_t = c_in_f;
        
        #5;
        clk_t = 1;
        #10;
        clk_t = 0;
        
        if (c_out_t != c_out_f) begin
            $display("Something wrong with rst = %0b d_in = %0h. c_out should be %0h but is instead %0h", rst_f, c_in_f, c_out_f, c_out_t);
            $finish;
        end
    end
    $display("all tests passed");
    $fclose(file_pointer);
    $finish;
end
endmodule
