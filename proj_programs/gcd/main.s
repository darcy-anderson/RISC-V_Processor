/*
 * Standalone assembly language program for NYU-6463-RV32I processor
 * The label 'reset handler' will be called upon startup.
 */
.global reset_handler
.type reset_handler,@function

reset_handler:
    li a0, 0x00100010           # Get address for switch register
    lhu a1, 0(a0)               # Load 16-bit switch values 

    # Separate switch values into two 8-bit integers
    li a2, 0xFF                 # Lower 8 bits mask
    and a0, a1, a2              # Extract lower integer into a0
    srli a1, a1, 8              # Shift to get upper integer in a1

gcd:
    beq a0, a1, end             # If a == b, go to end
    blt a1, a0, b_lessthan_a    # If a > b, branch

a_lessthan_b:
    sub a1, a1, a0              # b = b - a
    j gcd                       # Loop

b_lessthan_a:                   
    sub a0, a0, a1              # a = a - b
    j gcd                       # Loop

end:
    li a2, 0x00100014           # Get address for LED register
    sh a0, 0(a2)                # Store 16-bit LED values

    




