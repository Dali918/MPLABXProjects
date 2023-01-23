#### Dalitso Banda
	
# EECE.3170: Microprocessors I
# UMass Lowell
# Instructor: M. Geiger
    
# Question 3 for HW 2 ****SEE UPDATE BELOW FROM 9/30****
#
# The program below contains several comments (all of which start with ##)
#   describing an operation to be performed on one or more of the variables
#   declared at the start of the program. Replace each ## comment with *one*
#   appropriate instruction to complete the program (or, as I've done below,
#   simply move each comment to the right of the instruction)
	
### EACH INSTRUCTION YOU USE MUST BE A BITWISE, SHIFT, OR ROTATE INSTRUCTION

#######################
##### UPDATE 9/30 #####
#######################
# TWO OF THE "INSTRUCTIONS" LISTED BELOW ACTUALLY REQUIRE MULTIPLE INSTRUCTIONS
#  THESE LINES HAVE BEEN MARKED, AND YOU ARE ALLOWED TO USE >1 INSTRUCTION FOR
#  EACH ONE OF THE MARKED LINES (THE LINES THAT CHANGE $t0, $t1, AND $t6)

#   This program gives you some practice working with bitwise,
#     shift, and rotate operators

        .global    main

        .data
v1:	.word	12
v2:	.word	0xFEEDABEE

        .text
        .set	noreorder
        .ent	main

main:
	lw	$s1, v1		## $s1 = v1
	lw	$s2, v2		## $s2 = v2
## ***REQUIRES >1 INSTRUCTION***: $t0 = v2 with lowest 8 bits cleared (set to 0), other bits staying the same 
	li  $t0, 0xFFFFFF00
	and $t0, $t0, $s2
## ***REQUIRES >1 INSTRUCTION***: $t1 = v2 with 8 highest bits set to 1, other bits staying the same 
	lui $t1, 0xFF00
	ins $t1, $s2,0,24	
## $t2 = v1 multiplied by 8 *without* using a multiply instruction
	sll $t2, $s1,3
## $t3 = v2 shifted so that original least-significant byte is most-significant byte of $t3 and lower bits are 0
	ins $t3,$s2,24,8
## $t4 = v1 divided by 4 *without* using a divide instruction
	srl $t4, $s1,2
## $t5 = v2 with the upper and lower half-words swapped (so result is 0xABEEFEED)
	rotr $t5, $s2,16
## ***REQUIRES >1 INSTRUCTION***: $t6 = v2 with middle 8 bits flipped, other bits staying the same 
##	mov $t6,$s2
##	not $t7,$s2
	srl $t7,$t7,12
##	ins $t6,$t7,12,8
##**I tried to use the above instructions in MPLAB, however they did not work (the not and mov instuctions where not funcitonal).
##**I assume it is because they are pseudo instructions
##**However, I have explicitely implemented the psuedo instructions below 
	add $t6, $s2, $zero
##**the next two lines implement a not gate using xor: one of the inputs being logical 1 and the ##**other the input we are trying to negate
	li  $t7, 0xFFFFFFFF 
	xor $t8, $s2, $t7
##**we can now go ahead and replace the middle 8 bits of the original data with its flipped version	
	srl $t8, $t8,12
	ins $t6,$t8,12,8
	
	
	
	
# This code simply loops infinitely--we'll cover jump (j) instructions soon
spin:   j          spin
        nop

       .end        main