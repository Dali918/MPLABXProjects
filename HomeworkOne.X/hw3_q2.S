#### Dalitso Banda
	
# EECE.3170: Microprocessors I
# UMass Lowell
# Instructor: M. Geiger
    
# Question 2 for HW 3
# Your solution should implement the following loop:


	
    .global    main
    .data

### THESE VARIABLES ARE SIMPLY GIVEN VALUES TO START
###   WITH--CHANGE THEIR VALUES AND VERIFY YOUR PROGRAM
###   WORKS APPROPRIATELY IN ALL CASES
A:  .int    1
B:  .int    100
X:  .int    20
	
    .text
    .set       noreorder
    .ent       main

main:
    # Load variables into registers
    lw  $t0, A
    lw  $t1, B
    lw  $t2, X
    
    add	    $t3, $zero, $zero	# set $t3 to 0 which will be the iteration counter
    
    L1:
	beq	$t0, $t1, store	# check to see if A and B are equal 
	nop			# and branch to store if true 
	
	beq	$t3, $t2, store	# check to see if number of iterations $t3==X, 
	nop			# and branch to store if true 
	
	add	$t0, $t0, $t2	# increment A by X
	sub	$t1, $t1, $t2	# decrement B by X
	addi	$t3, $t3, 1	# increment $t3 (counter) by 1
	j    L1			#jump back to L1 for next iteration
	nop
    store: 
	sw	$t0, A	# update A after loop is terminated
	sw	$t1, B	# update B after loop is terminated
	j	spin	# jump to spin
    nop
    # Implement loop described above
    # Make sure final values for A and B are in memory
    #   (but you don't necessarily have to update memory
    #    in every loop iteration)
	
# This code simply loops infinitely
spin:
    j          spin
    nop

    .end        main    