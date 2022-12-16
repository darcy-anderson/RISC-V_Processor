# Makefile modified by Hammond Pearce for NYU-6463-RV32I
# Date: 2021-10-18
# ------------------------------------------------------------

# GCC toolchain programs.
CC = riscv32-unknown-elf-gcc
OC = riscv32-unknown-elf-objcopy
OS = riscv32-unknown-elf-size
OD = riscv32-unknown-elf-objdump

# Assembly directives.
ASFLAGS += -c
ASFLAGS += -O0
ASFLAGS += -Wall
ASFLAGS += -fmessage-length=0
ASFLAGS += -march=rv32i
ASFLAGS += -mabi=ilp32
ASFLAGS += -mcmodel=medlow
# C compilation directives
CFLAGS += -c
CFLAGS += -Wall
CFLAGS += -O0
CFLAGS += -g
CFLAGS += -fmessage-length=0
CFLAGS += --specs=nosys.specs
CFLAGS += -march=rv32i
CFLAGS += -mabi=ilp32
CFLAGS += -mcmodel=medlow
# Linker directives.
LFLAGS += -Wall
LFLAGS += -Wl,--no-relax
LFLAGS += -Wl,--gc-sections
LFLAGS += -nostdlib
LFLAGS += -nostartfiles
LFLAGS += -lc
LFLAGS += -lgcc
LFLAGS += --specs=nosys.specs
LFLAGS += -march=rv32i
LFLAGS += -mabi=ilp32
LFLAGS += -mcmodel=medlow
LFLAGS += -T./nyu-6463-rv32i.ld
# Source files.
AS_SRC  = ./main.s

# Header file directories.
INCLUDE = -I./
# Object files to build.
OBJS  = $(AS_SRC:.s=.o)

# Default rule to build the whole project.
.PHONY: all
all: main.bin main.hex main.mem main.dump
# Rule to build assembly files.
%.o: %.s
	$(CC) -x assembler-with-cpp $(ASFLAGS) $(INCLUDE) $< -o $@
# Rule to create an ELF file from the compiled object files.
main.elf: $(OBJS)
	$(CC) $^ $(LFLAGS) -o $@
# Rule to create a raw binary file from an ELF file.
main.bin: main.elf
	$(OC) -S -O binary $< $@
	$(OS) $<
# Rule to create a verilog hex file from a raw binary file (for Verilog readmemh).
main.verilog.bytes.mem: main.elf
	$(OC) -S -O verilog --verilog-data-width=1 $< $@
# Rule to create a VHDL hex file from a raw binary file (for VHDL textio).
main.vhdl.bytes.mem: main.bin
	hexdump -ve '1/1 "%.2x\n"' $< > $@
main.mem: main.bin
	hexdump -ve '1/4 "%.8x\n"' $< > $@
# Rule to create a intel hex file from a raw binary file (for VHDL megafunction).
main.hex: main.elf
	$(OC) -S -O ihex $< $@
#Rule to create main.dump from file
main.dump: main.elf
	$(OD) --syms -d $< > $@
# Rule to clear out generated build files.
.PHONY: clean
clean:
	rm -f $(OBJS)
	rm -f main.elf
	rm -f main.bin
	rm -f main.dump
	rm -f main.hex
	rm -f main.vhdl.bytes.mem
	rm -f main.verilog.bytes.mem
	rm -f main.mem