## ***** ADD YOUR NAME IN A COMMENT AT THE START OF THE FILE *****
## Dalitso Banda    
## EECE.3170: Microprocessors I
## UMass Lowell
## Instructor: M. Geiger
    
## Program 2 for midterm exam
    
## This partially written program is similar to the problems
##   on HW 3. This program should read the contents of an array,
##   arr, in which the last value in the array is equal to 0
##   The program should count the number of negative and positive values
##   in the array and store the final count of each in two memory
##   variables, nNeg and nPos. The 0 value at the end of the array
##   should *not* be counted.
    
## The comments below describe generally how the program should behave
## Note that:
##      1. Pseudo-instructions are acceptable, but 32-bit immediates are not
##          in most cases (li being an exception)
##      2. Your solution should be general--don't write code that only
##          works for the sample variable values given.
##      3. Your solution should successfully assemble and run--code that does
##          not assemble will lose credit
    
    .data
## arr = Data to be tested
arr:	.word	    5, -3, 7, 4, -10, -18, 2020, 9, -1, 1, 0	    

## nNeg = # of negative values in arr; nPos = # of positive values in arr
nNeg:   .space	    4
nPos:	.space	    4
    	
    .text		# Text section contains code
    .set noreorder	# Disable instruction reordering
    .globl main		# Define main label as a global entity
    .ent main		#   and an entry point   

main:

    ## Initialize registers to hold array starting address
    ##   & negative/positive value counts
    la	    $t0, arr			# array address
    and	    $t1, $zero, $t1		# negative counter
    and	    $t2, $zero, $t2		# positive counter
    ## *** ADD YOUR CODE HERE ***
    
    ##
    ## Loop to test all array values
    ##  In each iteration, loop should:
    ##  1. Load current array value into a register
    ##  2. If the value is 0, exit the loop
    ##  3. Otherwise, test if it's negative or positive and update
    ##       the appropriate count (hint: you only have to actually
    ##       test one of those conditions, since you've already
    ##       checked if value's 0. For example, if value isn't 0 and
    ##       isn't negative, it must be positive.)
    ##  4. Update address register to refer to next array element and restart loop
    ##
loop:
    ## *** ADD YOUR CODE HERE ***
    check:
	lw	    $t3, 0($t0)		    # load the current value into $t3
	beq	    $t3, $zero, done	    # if current == 0 exit loop
	nop				    # delay slot
	slt	    $t3, $t3, $zero	    # $t3 == 1 if current < 0
	beq	    $t3, $zero, positive    # branch to 'positive' if $t3 == 0
	nop				    # delay slot
	addi	    $t1, $t1, 0x0001	    # increment negative counter
    next:
	addi	    $t0, $t0, 0x0004	    # get address of the next value in the array
	j	    check		    # jump back to start of loop
	nop				    # delay slot
    positive:
	addi	    $t2, $t2, 0x0001	    # increment the positive count
	j	    next		    # jump to next
	nop				    # delay slot
    ## Once loop is done, move count values into appropriate memory variables
done:
    ## *** ADD YOUR CODE HERE ***    
    sw	    $t1, nNeg			    # store negative count
    sw	    $t2, nPos			    # store positive count 
    j	    spin 
    nop
spin:
    j	spin
    nop
    
    .end main