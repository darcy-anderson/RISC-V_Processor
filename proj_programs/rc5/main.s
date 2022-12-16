/*
 * Standalone assembly language program for NYU-6463-RV32I processor
 * The label 'reset handler' will be called upon startup.
 */
.global reset_handler
.type reset_handler,@function

reset_handler:
main:
    // some memory location saved at x8, saving rom key
    add     s0,sp,r0
    li      a5, 0x46F8E8C5 // first rom key, after two zeros
    sw      a5, -148(s0)
    li      a5, 0x460C6085
    sw      a5, -144(s0)
    li      a5, 0x70F83B8A
    sw      a5, -140(s0)
    li      a5, 0x284B8303
    sw      a5, -136(s0)
    li      a5, 0x513E1454
    sw      a5, -132(s0)
    li      a5, 0xF621ED22
    sw      a5, -128(s0)
    li      a5, 0x3125065D
    sw      a5, -124(s0)
    li      a5, 0x11A83A5D
    sw      a5, -120(s0)
    li      a5, 0xD427686B
    sw      a5, -116(s0)
    li      a5, 0x713AD82D
    sw      a5, -112(s0)
    li      a5, 0x4B792F99
    sw      a5, -108(s0)
    li      a5, 0x2799A4DD
    sw      a5, -104(s0)
    li      a5, 0xA7901C49
    sw      a5, -100(s0)
    li      a5, 0xDEDE871A
    sw      a5, -96(s0)
    li      a5, 0x36C03196
    sw      a5, -92(s0)
    li      a5, 0xA7EFC249
    sw      a5, -88(s0)
    li      a5, 0x61A78BB8
    sw      a5, -84(s0)
    li      a5, 0x3B0A1D2B
    sw      a5, -80(s0)
    li      a5, 0x4DBFCA76
    sw      a5, -76(s0)
    li      a5, 0xAE162167
    sw      a5, -72(s0)
    li      a5, 0x30D76B0A
    sw      a5, -68(s0)
    li      a5, 0x43192304
    sw      a5, -64(s0)
    li      a5, 0xF6CC1431
    sw      a5, -60(s0)
    li      a5, 0x65046380
    sw      a5, -56(s0)

    // read switch input
    li      a5, 0x00100010
    lh      a5, 0(a5)
    sw      a5,-28(s0)

    sw      zero,-32(s0)
    sw      zero,-36(s0)
    sw      zero,-40(s0)
    sw      zero,-44(s0)
    sw      zero,-48(s0)
    sw      zero,-52(s0)
    lw      a5,-28(s0)
    sw      a5,-20(s0)
    li      a5,1
    sw      a5,-24(s0)
    j       .L2

.L3:
    lw      a4,-44(s0)
    lw      a5,-20(s0)
    xor     a5,a4,a5
    sw      a5,-32(s0)

    lw      a4,-32(s0) // ab_xor
    lw      a5,-20(s0) // b_reg
    sll     a5,a4,a5
    sw      a5,-36(s0)
    lw      a5,-24(s0) // i _cnt
    slli    a5,a5,1    // i_cnt * 2
    slli    a5,a5,2    // i_cnt * 4 as address
    addi    a5,a5,-16
    add     a5,a5,s0
    lw      a4,-140(a5) // a5 + -16 + -140 => a5 -156 => first element is 148
    lw      a5,-36(s0)
    add     a5,a4,a5
    sw      a5,-40(s0)
    lw      a4,-20(s0)
    lw      a5,-40(s0)
    xor     a5,a4,a5
    sw      a5,-48(s0)
    lw      a5,-48(s0)
    lw      a3,-40(s0)
    sll     a3,a5,a3
    sw      a3,-52(s0)
    lw      a5,-24(s0)
    slli    a5,a5,1
    addi    a5,a5,1
    slli    a5,a5,2
    addi    a5,a5,-16
    add     a5,a5,s0
    lw      a4,-140(a5) // a5 - 152
    lw      a5,-52(s0)
    add     a5,a4,a5
    sw      a5,-20(s0)
    lw      a5,-24(s0)
    addi    a5,a5,1
    sw      a5,-24(s0)
.L2:
    lw      a4,-24(s0) // i_cnt
    li      a5,12      // i_cnt < 13
    ble     a4,a5,.L3
    // write lower 16 bits of b reg to led
    lw      a4,-20(s0)
    li      a5, 0x00100014
    sw      a4, 0(a5)   // turn on led
