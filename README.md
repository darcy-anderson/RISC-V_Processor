# NYU-6463-RV32I Processor Design Project - Group 6

## Project Members

Ordered by last name alphabetically

- D'Arcy Anderson - dra5066
- Irving Fang - zf540
- Jayeon Koo - jk7134

## Implemented Modules
For this milestone we implemented the following modules. The Control Unit is not necessarily required, but still implemented. Some axuiliary modules like Branch Comparison or Immediate Extender are not implemented because we need to furthur design them when we interconnect all the modules.

All the implemented modules can be found at `project_code\project_code.srcs\sources_1\new`

1. **Program Counter** (`program_counter.v`):
   - Currently it resets to `0x01000000` when `rst` is high.
   - Otherwise it just outputs the address it receives. We want to do the address increment in the Control Unit, but this design may change when we actually interconnect components
2. **Control Unit** (`control.v`)
   - This is a preliminary control unit that is responsible for instruction decode and sending respective control signals to different modules. We expect a lot more updates to be made as we connect the datapaths together.
   - At the moment, control signals of the following are generated; this list is subject to change
      - regWrite for write back to register file
      - memRead for memory access on load
      - memWrite for memory access on store
      - memToReg for write back on load
      - aluSrc to select rt or immediate as the 2nd argument to ALU
      - aluOp to select which ALU operation to execute
      - branch to select PC+4 or immediate
     
3. **Register File** (`register_file.v`):

   - It initializes all 32 registers to 0.
   - Writing to `Rd` is only available when `w_en == 1`.
   - Reading to `R1` and `R2 is only available when `r_en == 1`.
   - It prohibits writing to `R0`.

4. **ALU** (`ALU.v`)

   - It uses `funct7` and `funct7` to identify instruction. This may change when we interconnect it with the Control Unit
   - It can perform `ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND`, but not anything related to immediate. We will see if we need specialized code for immediate when we do the interconnection.

5. **Instruction Memory** (`instr_mem.v`)

   - Consists of a single set of 4-byte wide read-only memory. Instructions are initialized from `main.mem`, and read each cycle per the input address from the program
     counter. Only word-aligned address accesses are possible.

6. **Data Memory** (`data_mem.v`)
   - The data memory structure consists of 4 interweaved sets of 1-byte wide memory. It supports writing words, half-words, and bytes, to any byte-addressed memory location.
   - Accessed addresses do not have to be aligned, and there should be no performance decrease versus aligned addresses. Currently only full word reading is supported, with
     the assumption that masking the unwanted bits in LH/LB instructions will be performed in the control circuitry. Misaligned reading is also possible.

## Testbench

You can find the python script we use to generate test cases and the test case files themselves in `project_util/`

All the implemented testbenchs are in `project_code\project_code.srcs\sim_1\new`

1. **Program Counter** (`program_counter_testbench.v`):
   - The testbench first tests if the PC will output the correct output when given input.
   - The testbench then tests whether PC resets to the start of memory when `rst` is high by having 50% chance of setting `rst = 1` at each clock cycle.
2. **Control Unit**
   - Control unit test bench has been ommitted for this milestone as this module was not a requirement for this submission and the team is still brainstorming on the best approach to test control signals. At the moment, a test driven approach of writing a test case for a specific instruction type and ensuring that instruction can be ran successfully, and repeating this process iteratively for different instructions, seem like the most adequate. 
   
3. **Register File** (`register_file_testbench.v`):

   - The testbench first tests if read and write are implemented correctly by writing to all the registers and read from all the registers.
   - The testbench then tests writing to R0 is prohibited and reading R0 always gives 0 by writing to R0 and reading from R0
   - There are more randomized tests to be made by randomly messing with `w_en` and `r_en`, which will be done in the next month.

4. **ALU** (`ALU_testbench.v`)

   - The testbench simply tests all the operation by comparing the output from `ALU.v` with a Python implementation of such `ALU.v` when given random input data.

5. **Instruction Memory** (`testbench_instr_mem.v`)

   - First we populated every word of the memory with randomly generated 32-bit values in `main.mem` to emulate 32-bit instruction codes. The testbench then sequentially
     reads from each memory address to verify that the returned value is as expected.

6. **Data Memory** (`testbench_data_mem.v`)
   - The testbench alternates between writing data to a specific address, and then reading from the same address to verify the value is as expected. First, randomly generated
     full-word data is written to every possible aligned address, to verify that the full available memory is functional. Then misaligned word writes are used to test the
     writing of data to the next memory row. Then half-word and single-byte writes are tested. Finally, the edge case where a misaligned word is written at to the last
     addresses is tested, to confirm proper wrap-around to the first addresses, per the RISC-V ISA spec.