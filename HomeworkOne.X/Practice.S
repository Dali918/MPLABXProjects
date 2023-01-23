    .data
v1: .word 0x0000024C
v2: .word 0x000000AA
    
    
    
    .text 
    .set noreorder
    .globl main
    .ent main
    
main:
    la $s0, v1
    lw $s0, 0($s0)
    la $s1, v2
    lw $s1, 0($s1)
    and $s2, $s1,$s0
   addi $s1, $s0, 0xFFFD
   lw $s2, 0($s1)
  
    
    nop
.end main
    
    