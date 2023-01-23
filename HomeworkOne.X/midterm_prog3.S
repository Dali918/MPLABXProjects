## ***** ADD YOUR NAME IN A COMMENT AT THE START OF THE FILE *****
## Dalitso Banda
## EECE.3170: Microprocessors I
## UMass Lowell
## Instructor: M. Geiger
    
## Program 3 for midterm exam
    
## This partially written program is similar to the problems
##   on HW 3. You are responsible for writing the bitmask function, 
##   which takes 3 arguments, representing (1) a low bit position, 
##   (2) a high bit position and (3) a value to place in those bits, 
##   and returns a value with every bit between those two bit positions
##   set to the specified value. See the function description below for
##   more details.
    
## The comments below describe generally how the program should behave
## Note that:
##      1. Pseudo-instructions are acceptable, but 32-bit immediates are not
##          in most cases (li being an exception)
##      2. Your solution should be general--don't write code that only
##          works for the sample variable values given.
##      3. Your solution should successfully assemble and run--code that does
##          not assemble will lose credit
    
## NOTE: This program needs no data section--don't add one
    
    .text		# Text section contains code
    .set noreorder	# Disable instruction reordering
    .globl main		# Define main label as a global entity
    .ent main		#   and an entry point   

## main function tests your function, which is listed after main
##  DO NOT MODIFY THIS CODE AT ALL!
main:
    
##   $a0 = 0, $a1 = 31, $a2 = 1 --> return value = 0xFFFFFFFF
    add	    $a0, $zero, $zero
    addi    $a1, $zero, 31
    addi    $a2, $zero, 1
    jal	    bitmask
    nop    
    nop			# Function returns here--set a breakpoint to 
			#   check return value (should be 0xFFFFFFFF)
    
##   $a0 = 0, $a1 = 31, $a2 = 0 --> return value = 0x00000000
    add	    $a0, $zero, $zero
    addi    $a1, $zero, 31
    add	    $a2, $zero, $zero
    jal	    bitmask
    nop
    nop			# Function returns here--set a breakpoint to 
			#   check return value (should be 0x00000000)
    
##   $a0 = 6, $a1 = 11, $a2 = 1 --> return value = 0x00000FC0
    addi    $a0, $zero, 6
    addi    $a1, $zero, 11
    addi    $a2, $zero, 1
    jal	    bitmask
    nop
    nop			# Function returns here--set a breakpoint to 
			#   check return value (should be 0x00000FC0)
    
##   $a0 = 16, $a1 = 31, $a2 = 0 --> return value = 0x0000FFFF
    addi    $a0, $zero, 16
    addi    $a1, $zero, 31
    addi    $a2, $zero, 0
    jal	    bitmask
    nop
    nop			# Function returns here--set a breakpoint to 
			#   check return value (should be 0x0000FFFF)
			
##   $a0 = 8, $a1 = 23, $a2 = 0 --> return value = 0xFF0000FF
    addi    $a0, $zero, 8
    addi    $a1, $zero, 23
    addi    $a2, $zero, 0
    jal	    bitmask
    nop
    nop			# Function returns here--set a breakpoint to 
			#   check return value (should be 0xFF0000FF)
    
spin:
    j	spin
    nop
    
    .end main
    
##
## bitmask function, which you must complete
## Function arguments are as follows:
##   $a0 = low bit position (between 0 & 31)
##   $a1 = high bit position (between 0 & 31)
##   $a2 = value to place in specified positions (either 0 or 1)
## Function should return bit mask with specified value in all positions
##    and opposite value in all other bits. Recall that least significant
##    bit of any register has position 0, most significant bit has position 31
## For example, if:
##   $a0 = 0, $a1 = 31, $a2 = 1 --> return value = 0xFFFFFFFF
##   $a0 = 0, $a1 = 31, $a2 = 0 --> return value = 0x00000000
##   $a0 = 6, $a1 = 11, $a2 = 1 --> return value = 0x00000FC0
##   $a0 = 16, $a1 = 31, $a2 = 0 --> return value = 0x0000FFFF
##   $a0 = 8, $a1 = 23, $a2 = 0 --> return value = 0xFF0000FF
##
bitmask:

## *** ADD YOUR CODE HERE ***
##
    add	    $t0, $zero, $zero		    # designate an empty register
    li	    $t0, 0x001F			    # $t0 = 31
    sub	    $t0, $t0, $a1		    # $t0 = 31 - high bit position
    li	    $t1,0xFFFFFFFF		    # load $t1 with all 1's
    srl	    $t2, $t1, $t0		    # logical shift $t1 right by $t0 and store to $t2 
    sll	    $t3, $t1, $a0		    # shift $t1 left by $a0 and store to $t3
    and	    $t4, $t2, $t3		    # AND $t2 and $t3
    bne	    $a2, $zero, done		    # if $a2 == 1 then done
    nop					    # delay slot
    xor	    $t4, $t4, $t1		    # else NOT the result using XOR
	
## Hints:
##   1. There are multiple ways to solve this problem, 
##        but I found shift instructions very helpful
##   2. When starting your bitmask, it's much easier to
##        work with a group of ones than it is a group of zeroes
##   3. Hint #2 holds regardless of the value of $a2--if you need
##        a bitmask with 0s in certain positions, it'll be easiest
##        to build the inverse bitmask (1s in those positions) and
##        then flip the bits
##
    
## End function--may need to jump/branch here at some point    
done:
    add	    $v0, $zero, $t4	    # save the result to $v0
    jr	    $ra			    # Return from function
    nop