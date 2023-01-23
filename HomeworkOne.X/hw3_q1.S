#### Dalitso Banda
	
# EECE.3170: Microprocessors I
# UMass Lowell
# Instructor: M. Geiger
    
# Question 1 for HW 3
# Your solution should implement the following conditional statement:

	
    .global    main
    .data

### THESE VARIABLES ARE SIMPLY GIVEN VALUES TO START
###   WITH--CHANGE THEIR VALUES AND VERIFY YOUR PROGRAM
###   WORKS APPROPRIATELY IN ALL CASES
A:  .int    21
B:  .int    1
C:  .int    7
D:  .int    0
	
    .text
    .set       noreorder
    .ent       main

main:
    # Load variables into registers
    lw	    $t0, A
    lw	    $t1, B
    lw	    $t2, C
    la	    $t3, D		# load the memory address of variable D
    
				## if block
    slti    $t4, $t0, 10	# A < 10 comparison. store the result in $t4
    bne	    $t4, $zero, L1	# if true then $t4!=0, branch to L1
    nop
				## else if block
    addi    $t4, $t0, -20	# subtract 20 from $t0, store the result in $t4
    beqz    $t4, L2		# if $t4==0 then $t0=20 and branch to L2
    nop
				## else block with code
    add	    $t4, $t1, $t2	# add C and B together and store the result in $t4
    sw	    $t4, 0($t3)		# load the result to D
    j	    spin		# jump to spin
    nop
    
				## if block - code
    L1:
	addi	$t4, $t2, 10	# add 10 to C
	sw	$t4, 0($t3)     # load the result to D
	j	spin		# jump to spin
	nop
  
				## else if block - code
    L2:
	sub	$t4, $t2, $t1	# C-B and store the result in $t4
	sw	$t4, 0($t3)	# load the result to D
	j	spin		# jump to spin
	nop
    
    # Implement conditional statement described above
    # Make sure final result is in memory in variable "D"
	
# This code simply loops infinitely
spin:   
    j          spin
    nop

    .end        main    