`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////


module cpu(
    input wire clk,
    input wire rst,
    input wire [15:0] sw,
    output wire [15:0] led
    );
    
// >> State Machine <<
localparam [2:0]
    halt    = 3'b111,
    idle    = 3'b000,
    fetch   = 3'b001,
    decode  = 3'b010,
    execute = 3'b011,
    memory  = 3'b100,
    write   = 3'b101;
reg[2:0] state_curr, state_next;

always @ (negedge clk, posedge rst)
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

wire        cs_exe_reg_write_en;
wire [3:0]  cs_exe_data_op;
wire [2:0]  cs_exe_branch_op;
wire        cs_exe_branch_result;
wire [1:0]  cs_exe_imm_op; // I made a change here. Now it's 2 bit instead of the original 3
wire [19:0] cs_exe_imm_data;

wire cs_exe_r1_sel;
wire cs_exe_r2_sel;

// -- MEMORY --
wire cs_mem_en;
wire cs_mem_we;
wire cs_mem_se;
wire [1:0] cs_mem_bs;
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

assign pc_curr_increment = pc_curr + 3'b100; // best place here?
assign pc_jump = exe_rd_output_data;
assign pc_next_inst = cs_jump_en? pc_jump : pc_curr_increment;

// -- INSTRUCTION DECODE --     
instr_mem im(.clk(clk),
             .imem_en(cs_id_en),
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
//           .memControl(cs_mem_control), -> should be divided to multiple parts?
           .regWriteEn(cs_exe_reg_write_en),
           .regWriteBackDataSel(cs_wb_data_sel),
           .linkRegWriteEn(cs_wb_pc_addr));

assign exe_rd = id_instr[11:7];
assign exe_r1 = id_instr[19:15];
assign exe_r2 = id_instr[24:20];          

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
     
BranchCompare bc(.rs1(exe_r1_data),
                 .rs2(exe_r2_data),
                 .opcode(cs_exe_branch_op),
                 .out(cs_exe_branch_result));     

imm_ext ie(.imm_ext_en(cs_exe_imm_op),
           .imm_in(cs_exe_imm_data),
           .imm_out(exe_imm_extended));

assign exe_alu_s1_data = (cs_exe_r1_sel)? exe_r1_data : pc_curr;
assign exe_alu_s2_data = (cs_exe_r2_sel)? exe_imm_extended : exe_r2_data;
assign exe_write_data = cs_wb_pc_addr? pc_curr_increment: cs_wb_data_sel? mem_data_out: exe_rd_output_data; // currently not taking cs_wb_data_sel and cs_wb_pc_addr into account

// -- MEMORY --
data_mem dm(.clk(clk),
            .mem_en(cs_mem_en),
            .mem_we(cs_mem_we),
            .mem_se(cs_mem_se),
            .mem_bs(cs_mem_bs),
            .addr(mem_addr),
            .data_in(mem_data_in),
            .data_out(mem_data_out),
            .sw_in(sw),
            .led_out(led));



endmodule