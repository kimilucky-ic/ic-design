.section .text.startup,"ax",@progbits
.globl _start
.type _start,@function
_start:
    la sp, __stack_top
    la t0, __bss_start
    la t1, __bss_end
1:
    bgeu t0, t1, 2f
    sw zero, 0(t0)
    addi t0, t0, 4
    j 1b
2:
    la t0, __data_load_start
    la t1, __data_start
    la t2, __data_end
3:
    bgeu t1, t2, 4f
    lw t3, 0(t0)
    sw t3, 0(t1)
    addi t0, t0, 4
    addi t1, t1, 4
    j 3b
4:
    li a0, 0
    li a1, 0
    call main
    li t0, 1
    li t1, 0x1000000c
    sw t0, 0(t1)
5:
    j 5b
.size _start, .-_start
