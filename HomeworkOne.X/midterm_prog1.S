## ***** ADD YOUR NAME IN A COMMENT AT THE START OF THE FILE *****
## Dalitso Banda    
## EECE.3170: Microprocessors I
## UMass Lowell
## Instructor: M. Geiger
    
## Program 1 for midterm exam
    
## This partially written program is similar to the problems
##   on HW 2. The program contains 10 comments, numbered C1-C10, and each
##   comment describes an operation that can be done in *one* instruction.
##   (No, really, I mean it this time--only one instruction.)
## Replace each comment with a single instruction that performs the
##   designated operation. Note that:
##      1. Pseudo-instructions are acceptable, but 32-bit immediates are not
##          in most cases (li being an exception)
##      2. Your solution should be general--don't write code that only
##          works for the sample variable values given.
##      3. Your solution should successfully assemble and run--code that does
##          not assemble will lose credit
    
    .data
v1:	.word	    10
v2:	.word	    -100
v3:	.word	    0x10192020
   
    .text		# Text section contains code
    .set noreorder	# Disable instruction reordering
    .globl main		# Define main label as a global entity
    .ent main		#   and an entry point   

main:
    
    ## Copy variables into registers
    lw	    $t0, v1
    lw	    $t1, v2
    lw	    $t2, v3
    
    ## *** START ADDING CODE BELOW THIS POINT--REPLACE EVERY COMMENT NUMBERED C1-C10
    ## C1: $t3 = $t0 * 2, without using a multiply instruction
    sll	    $t3, $t0, 1
    ## C2: $t4 = $t1 / 4, without using a divide instruction AND keeping the sign intact
    sra	    $t4, $t1, 2
    ## C3: $t5 = $t2 with the lowest 16 bits flipped (inverted) and the upper 16 bits staying the same
    xori    $t5, $t2, 0xFFFF
    ## C4: $t6 = $t4 * $t5
    mul	    $t6, $t4, $t5
    ## C5: $t7 = 0xFFF00000 without using the li pseudo-instruction
    lui	    $t7, 0xFFF0
    ## C6: $t8 = value in $t2 with all bits cleared except the upper 12 bits (USE THE VALUE IN $t7 FOR THIS INSTRUCTION)
    nor	    $t8, $t7, $t2
    ## C7: $t9 = difference between $t8 and $t6
    sub	    $t9, $t8, $t6
    ## C8: $s0 = 1 if $t9 < $t8; otherwise, $s0 = 0
    slt	    $s0, $t9, $t8
    ## C9: Branch to label "spin" if $s0 = 1
    bne	    $s0, $zero, spin
    nop	    ## Leave this instruction--fills delay slot for instruction you write above for comment C9
    
    ## C10: Rotate $t2 so original most significant byte becomes least significant byte, and all other bits move left by 8 bits
    ##    (so, given example value of 0x10192020, $s1 would be 0x19202010)
    rotr   $s1,$t2,24
spin:
    j	spin
    nop
    
    .end main