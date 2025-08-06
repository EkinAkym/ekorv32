.global _boot
.text

_boot:                    /* x0  = 0    0x000 */
       auipc x1, 0
       addi x1, x1, 32
       lui x2, 0x1
       addi x8, x0, 2
       div x2,x2,x8
       addi x3, x0, 10
       addi x4, x0, 20
       add x5, x3, x4
       sub x6, x4, x3
       sw x5, 0(x2)
       lw x7, 0(x2)
