#### Dalitso Banda
	
# EECE.3170: Microprocessors I
# UMass Lowell
# Instructor: M. Geiger
    
# Question 3 for HW 3
# You must complete the "minimum" function, which goes through
#   an array of non-negative integer values and returns the
#   lowest value in the array
# Function is listed after main
	
    .global    main
    .data

# In each array, 1st value = # of values in array
#  Values to be tested start with 2nd value (1 in arr1,
#   17 in arr2, 10 in arr3
# Please, DO NOT change array values for testing
arr1:  .word	5, 1, 4, 15, 100, 102
arr2:  .word    6, 17, 13, 10, 9, 8, 5
arr3:  .word	10, 10, 8, 20, 3, 17, 0, 2020, 11, 7, 21
	
    .text
    .set       noreorder
    .ent       main

main:
    la  $a0, arr1	    # a0 = starting address of arr1
    lw	$a1, 0($a0)	    # a1 = # values in arr1
    jal	minimum
    nop
    add	$s0, $v0, $zero	    # Copy 1st return value to $s0
    la	$a0, arr2	    # a0 = starting address of arr2
    lw	$a1, 0($a0)	    # a1 = # values in arr2
    jal	minimum
    nop
    add	$s1, $v0, $zero	    # Copy 2nd return value to $s1
    la	$a0, arr3	    # a0 = starting address of arr3
    lw	$a1, 0($a0)	    # a1 = # values in arr3
    jal	minimum
    nop
    add	$s2, $v0, $zero	    # Copy 3rd return value to $s2
    	
# This code simply loops infinitely
spin:   
    j          spin
    nop

# minimum function, which you must complete
# Tests all values in array of non-negative 
#   When called: $a0 = starting address of array 
#                      (note: 1st value "in array" is # of values;
#			function should start with 2nd value in array)
#		 $a1 = number of values in array
#   Return minimum value in $v0

minimum:
    #### COMPLETE FUNCTION
    ####   Note: function should not require a stack frame, as you
    ####         should be able to do all work in temporary registers
    
    ## READ ME
    ## function in pseudo code:
    ## min = array[element2]
    ## for elementN in array:
    ##	    if array[elementN] < min
    ##	    min = array[elementN]
    ## return min
    
    ## Assumed that all array elements are 32 bits or 4 bytes
    addi    $t5, $a1, -1    # subtract the array element length by one
    addi    $t0, $zero, 1   # start the iteration counter at 1
    lw	    $t1, 4($a0)	    # load the value of the second element into $t1 as the 'current' min.
    addi    $t2, $a0, 0x8   # get the address of the third element as comparison with 
			    # the current min starts at the third element of the array
    
    check:
	lw  $t3, 0($t2)	    # get the element to be compared to min 
	slt $t4, $t1, $t3   # check if current min < array[i]
	beq $t4,$zero, update	# if current min < array[i] is false branch to update
	nop
	j increment	    # jump to increment for next iteration 
	nop
    update:
	add $t1, $t3, $zero # update the min accordingly
	j   increment	    # jump to increment for next iteration
	nop
    increment:
	beq $t0, $t5, exit  # exit loop if all array elements have been compared to min
	nop
	add $t0, $t0, 1	    # increment the iteration counter
	add $t2, $t2, 0x4   # update the address of the element being compared to min
	j   check	    # jump back to check for comparison
	nop
    exit:
	jr	$ra	    # Return from function call
	add	$v0, $t1, $zero	# $v0 = min for the delay slot
    .end        main    