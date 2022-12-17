/*
 * Standalone assembly language program for NYU-6463-RV32I processor
 * The label 'reset handler' will be called upon startup.
 */
.global reset_handler
.type reset_handler,@function

reset_handler:
# add
li x10, 0xFFFF
addi x0, x0, 0
li x11, 0x0FFF0000
add x12, x10, x11     # x12=0x0fFFFFFF

li x10, -0xFFFF
addi x0, x0, 0
li x11, 0x0FFF0000
add x12, x10, x11      # x12=0x0FFE0001

li x10, 0xFFFF
li x11, -0xFFFFF
add x12, x10, x11      # x12=0xfff10000

li x10, 5
addi x0, x0, 0
li x11, 2147483647
add x12, x10, x11      # x12=80000004 (overflow)

li x10, -5
addi x0, x0, 0
addi x0, x0, 0
li x11, -2147483648
add x12, x10, x11      # x12=0x7ffffffb (underflow)

# addi
addi x0, x0, 0
addi x0, x0, 0
addi x0, x0, 0
li x10, 0x0FFF0000
addi x12, x10, 0xFF  # x12=0x0fFF00FF

addi x0, x0, 0
addi x0, x0, 0
li x10, 2147483647
addi x12, x10, 5      # x12=80000004 (overflow)

addi x0, x0, 0
addi x0, x0, 0
addi x0, x0, 0
li x10, -2147483648
addi x12, x10, -5      # x12=0x7ffffffc (underflow)

# sub
li x10, 0xFFFF
addi x0, x0, 0
li x11, 0x0FFF0000
sub x12, x11, x10     # x12=0x0ffe0001

li x10, -0xFFFF
addi x0, x0, 0
li x11, 0x0FFF0000
sub x12, x11, x10      # x12=0x0fffffff

li x10, -5
addi x0, x0, 0
li x11, 2147483647
sub x12, x11, x10      # x12=80000004 (overflow)

li x10, 5
addi x0, x0, 0
addi x0, x0, 0
li x11, -2147483648
sub x12, x11, x10      # x12=0x7ffffffc (underflow)

# sll
li x10, 0xFFFF
addi x0, x0, 0
li x11, 8
sll x12, x10, x11      # x12=0x00FFFF00

li x10, 0xFFFF0000
addi x0, x0, 0
addi x0, x0, 0
li x11, 8
sll x12, x10, x11      # x12=0xFF000000

li x10, 0xFFFF
addi x0, x0, 0
li x11, 0xffffffe8
sll x12, x10, x11      # x12=0x00FFFF00

# slli
addi x0, x0, 0
addi x0, x0, 0
li x10, 0xFFFF
slli x12, x10, 8      # x12=0x00FFFF00

addi x0, x0, 0
addi x0, x0, 0
addi x0, x0, 0
li x10, 0xFFFF0000
slli x12, x10, 8      # x12=0xFF000000

# slt
li x10, 0xFFFF
li x11, 0xFFF0
slt x12, x11, x10    # x12=0x00000001

li x10, 0xFFFF
li x11, 0xFFF0
slt x12, x10, x11    # x12=0x00000000

li x10, 0xFFFF
li x11, 0xFFFF
slt x12, x11, x10    # x12=0x00000000

# slti
addi x0, x0, 0
addi x0, x0, 0
li x10, 0xFFFF
slti x12, x10, 5      # x12=0x00000000

addi x0, x0, 0
addi x0, x0, 0
addi x0, x0, 0
li x10, 10
slti x12, x10, 15    # x12=0x00000001

addi x0, x0, 0
addi x0, x0, 0
addi x0, x0, 0
li x10, 10
slti x12, x10, 10    # x12=0x00000000

# sltu
li x10, 0xFFFFFFFF
li x11, 0x0FFFFFFF
addi x0, x0, 0
sltu x12, x11, x10    # x12=0x00000001

# sltiu
addi x0, x0, 0
addi x0, x0, 0
addi x0, x0, 0
li x10, 0xFFFFFFFF
sltiu x12, x11, 5     # x12=0x00000000

# xor
li x10, 0xF0F0F0F0
li x11, 0xF0F00F0F
xor x12, x11, x10     # x12=0x0000FFFF

# xori
addi x0, x0, 0
addi x0, x0, 0
li x10, 0xF0F
xori x12, x10, 0x7F0  # x12=0x000000FF 

# srl
li x10, 0xFFFF0000
addi x0, x0, 0
addi x0, x0, 0
li x11, 8
srl x12, x10, x11     # x12=0x00FFFF00

li x10, 0xFFFF
addi x0, x0, 0
li x11, 8
srl x12, x10, x11     # x12=0x000000FF

addi x0, x0, 0
addi x0, x0, 0
li x10, 0xFFFF0000
li x11, 0xffffffe8
srl x12, x10, x11      # x12=0x00FFFF00

#srli
addi x0, x0, 0
addi x0, x0, 0
addi x0, x0, 0
li x10, 0xFFFF0000
srli x12, x10, 8     # x12=0x00FFFF00

addi x0, x0, 0
addi x0, x0, 0
li x10, 0xFFFF
srli x12, x10, 8     # x12=0x000000FF

#sra
addi x0, x0, 0
addi x0, x0, 0
li x10, 0xFFFF0000
li x11, 8
sra x12, x10, x11     # x12=0xFFFFFF00

addi x0, x0, 0
addi x0, x0, 0
li x10, 0x0FFF0000
li x11, 8
sra x12, x10, x11     # x12=0x000FFF00

#srai
addi x0, x0, 0
addi x0, x0, 0
addi x0, x0, 0
li x10, 0xFFFF0000
srai x12, x10, 8     # x12=0xFFFFFF00

addi x0, x0, 0
addi x0, x0, 0
addi x0, x0, 0
li x10, 0x0FFF0000
srai x12, x10, 8     # x12=0x000FFF00

#or
li x10, 0xF0F0F0F0
addi x0, x0, 0
li x11, 0xFFFF0000
or x12, x11, x10      # x12=0xFFFFF0F0

#ori
addi x0, x0, 0
addi x0, x0, 0
li x11, 0xF0F0F0F0
ori x12, x11, 0x7f0     # x12=0x00000FFF

#and
li x10, 0xF0F0F0F0
addi x0, x0, 0
li x11, 0xFFFFFFFF
and x12, x11, x10       # x12=0xF0F0F0F0

#andi
addi x0, x0, 0
addi x0, x0, 0
li x11, 0xF0F0F0F0
andi x12, x11, 0x7F0       # x12=0x00000700

