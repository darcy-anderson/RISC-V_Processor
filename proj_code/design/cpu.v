`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2022 05:48:09 PM
// Design Name: 
// Module Name: cpu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cpu(
    input wire clk,
    input wire rst
    );
    
// >> State Machine <<
localparam [2:0]
    halt = 3'b000,
    idle = 3'b001,
    fetch = 3'b010,
    decode = 3'b011,
    execute = 3'b100,
    memory = 3'b101,
    write = 3'b110;
reg[2:0] state_curr, state_next;

always @ (clk, rst)
begin
    if (rst)
        state_curr <= halt;
    else
        state_curr <= state_next;
end

always @(state_curr)
begin
    state_next = state_curr;
    
    case(state_curr)
        halt: state_next = idle;
        idle: state_next = fetch;
        fetch: state_next = decode;
        decode: state_next = execute;
        execute: state_next = memory;
        memory: state_next = write;
        write: state_next = fetch;
    endcase
end


// >> Connections and Control Signals << 

// -- INSTRUCTION FETCH --    
wire [31:0] pc_next_inst;        // computed next pc value
wire [31:0] pc_curr;             // current pc 
wire [31:0] pc_curr_increment;   // current pc + 4
wire [31:0] pc_jump;             // jump target if it exists, garbage value if it doesn't

wire cs_jump_en;

// -- INSTRUCTION DECODE --
wire [31:0] id_instr;      // current instruction 

// -- EXECUTE --
wire [4:0]  exe_rd;
wire [4:0]  exe_r1;
wire [4:0]  exe_r2;
wire [31:0] exe_write_data;
wire [31:0] exe_r1_data;
wire [31:0] exe_r2_data;
wire [31:0] exe_alu_s1_data;
wire [31:0] exe_alu_s2_data;
wire [31:0] exe_rd_output_data;
wire [31:0] exe_imm_extended;

wire        cs_exe_reg_write_data_sel;
wire        cs_exe_reg_write_en;
wire [3:0]  cs_exe_data_op;
wire [2:0]  cs_exe_branch_op;
wire        cs_exe_branch_result;
wire [2:0]  cs_exe_imm_op;
wire [19:0] cs_exe_imm_data;

wire cs_exe_r1_sel;
wire cs_exe_r2_sel;

// -- MEMORY --
wire [2:0]  cs_mem_control;
wire [31:0] mem_data_in;
wire [31:0] mem_data_out;
wire [31:0] mem_addr;

// -- WRITE BACK --
wire cs_wb_data_sel;
wire cs_wb_pc_addr;

// >> State Machine <<

wire cs_if_en; // state machine, need better name
wire cs_id_en;
wire cs_exe_en;  // state machine
wire cs_mem_en;
wire cs_wb_en;

assign cs_if_en  = (state_curr == fetch);
assign cs_id_en  = (state_curr == decode);
assign cs_exe_en = (state_curr == execute);
assign cs_mem_en = (state_curr == memory);
assign cs_wb_en  = (state_curr == write) & (cs_exe_reg_write_en == 1'b1);

// >> Components <<
// -- INSTRUCTION FETCH --    
program_counter pc (.clk(clk), 
                    .rst(rst),
                    .en(cs_if_en),
                    .c_in(pc_next_inst),
                    .c_out(pc_curr));
                    
program_counter_mux pcm (.clk(clk),
                         .jump_en(cs_jump_en),
                         .pc_increment(pc_curr_increment),
                         .pc_jump_target(pc_jump),
                         .pc_next(pc_next_inst));

assign pc_curr_increment = pc_curr + 3'b100; // best place here?

// -- INSTRUCTION DECODE --     
instr_mem im(.clk(clk),
             .pc_addr(pc_curr), 
             .instr_out(id_instr));

control c (.clk(clk),
           .inst(id_instr),
           .branchValid(cs_exe_branch_result),
           .branchEn(cs_jump_en),
           .immExtCtrl(cs_exe_imm_op),
           .imm_data(cs_exe_imm_data),
           .branchCompareOp(cs_exe_branch_op),
           .aluS1Sel(cs_exe_r1_sel),
           .aluS2Sel(cs_exe_r2_sel),
           .aluOp(cs_exe_data_op),
           .memControl(cs_mem_en),
           .regWriteEn(cs_wb_en),
           .regWriteBackDataSel(cs_wb_data_sel),
           .linkRegWriteEn(cs_wb_pc_addr));
           
// -- EXECUTE --
register_file rf(.clk(clk),
                 .rd(exe_rd),
                 .r1(exe_r1),
                 .r2(exe_r2),
                 .write_data(exe_write_data),
                 .w_en(cs_exe_reg_write_en),
                 .r_en(cs_exe_en),
                 .r1_read(exe_r1_data),
                 .r2_read(exe_r2_data));
                 
ALU alu(.operand1(exe_alu_s1_data), 
        .operand2(exe_alu_s2_data),
        .opcode(cs_exe_data_op),
        .out(exe_rd_output_data));             
     
branchALU balu(.s1(exe_r1_data),
               .s2(exe_r2_data),
               .opcode(cs_exe_branch_op),
               .branchResult(cs_exe_branch_result));     
               
imm_ext ie(.imm_ext_en(cs_exe_imm_op),
           .imm_in(cs_exe_imm_data),
           .imm_out(exe_imm_extended));

assign exe_alu_s1_data = (cs_exe_r1_sel)? exe_r1_data : pc_curr;
assign exe_alu_s2_data = (cs_exe_r2_sel)? exe_imm_extended : exe_r2_data;

// -- MEMORY --
data_mem dm(.clk(clk),
            .mem_en(cs_mem_en),
            .addr(mem_addr),
            .data_in(mem_data_in),
            .data_out(mem_data_out));



endmodule