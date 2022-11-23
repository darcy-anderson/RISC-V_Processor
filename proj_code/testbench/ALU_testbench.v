`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module ALU_testbench();

reg [31:0] operand1_t, operand2_t, operand1_f, operand2_f;
reg [6:0] funct7_t, funct7_f;
reg [2:0] funct3_t, funct3_f;
wire [31:0] out_t, out_f;

integer file_pointer;

ALU ALU_test(
    .operand1(operand1_t),
    .operand2(operand2_t),
    .funct7(funct7_t),
    .funct3(funct3_t),
    .out(out_t)
);

initial begin
    file_pointer = $fopen("ALU_tcases.txt", "r");
    if (file_pointer == 0) begin
        $display ("Could not open test cases file.");
        $stop;
    end

    while (!$feof(file_pointer)) begin
        $fscanf(file_pointer, "%b %b %b %b %b\n" , operand1_f, operand2_f, funct7_f, funct3_f, out_f);
        
        operand1_t = operand1_f;
        operand2_t = operand2_f;
        funct7_t = funct7_f;
        funct3_t = funct3_f;
        #10
        if (out_t != out_f) begin
            $display("Something wrong with operand1 = %0b operand2 = %0b, funct7 = %0b, funct3 = %0b. out should be %0b but is instead %0b", operand1_f, operand2_f, funct7_f, funct3_f, out_f, out_t);
            $finish;
        end
    end
    $display("all tests passed");
    $fclose(file_pointer);
    $finish;
end
endmodule
