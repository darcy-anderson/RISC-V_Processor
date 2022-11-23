`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////



module register_file_testbench();

reg clk_t, w_en_t, w_en_f, r_en_t, r_en_f;
reg [4:0] rd_t, rd_f, r1_t, r1_f, r2_t, r2_f;
reg [31:0] write_data_t, write_data_f;
wire [31:0] r1_read_t, r1_read_f, r2_read_t, r2_read_f;

integer file_pointer;

register_file reg_test(
    .clk(clk_t),
    .rd(rd_t),
    .r1(r1_t),
    .r2(r2_t),
    .write_data(write_data_t),
    .w_en(w_en_t),
    .r_en(r_en_t),
    .r1_read(r1_read_t),
    .r2_read(r2_read_t)
);
initial begin
    file_pointer = $fopen("reg_tcases.txt", "r");
    if (file_pointer == 0) begin
        $display ("Could not open test cases file.");
        $stop;
    end
    clk_t=0;
    while (!$feof(file_pointer)) begin
        $fscanf(file_pointer, "%b %b %b %b %b %b %b %b\n" , rd_f, r1_f, r2_f, write_data_f, w_en_f, r_en_f, r1_read_f, r2_read_f);
        
        #5; // assign test value in the middle of falling edge2
        rd_t = rd_f;
        r1_t = r1_f;
        r2_t = r2_f;
        write_data_t = write_data_f;
        w_en_t = w_en_f;
        r_en_t = r_en_f;
        
        #5;
        clk_t = 1;
        #10;
        clk_t = 0;
        
        if (r1_read_t != r1_read_f) begin
            $display("Something wrong with rd = %0d r1 = %0d r2 = %0d. r1_read should be %0h but is instead %0h", rd_f, r1_f, r2_f, r1_read_f, r1_read_t);
            $finish;
        end
        
        if (r2_read_t != r2_read_f) begin
            $display("Something wrong with rd = %0d r1 = %0d r2 = %0d. r2_read should be %0h but is instead %0h", rd_f, r1_f, r2_f, r2_read_f, r2_read_t);
            $finish;
        end
    end
    $display("all tests passed");
    $fclose(file_pointer);
    $finish;
end
endmodule
