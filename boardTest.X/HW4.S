# Dalitso Banda
# EECE.3170: Microprocessors I
# UMass Lowell
# Instructor: M. Geiger
# HW4
           
    .text		## Text section contains code
    .set noreorder	## Disable instruction reordering
    .globl main		## Define main label as a global entity
    .ent main

#include <xc.h>
main:
     /* Configure I/O ports--LEDs on Port A & C; switches on Port B */
    sw	    zero, ANSELA	    # set PORTA digital
    sw	    zero, ANSELB	    # set PORTB digital
    sw	    zero, ANSELC	    # set PORTC digital
    sw	    zero, TRISA		    # set PORTA output
    sw	    zero, TRISC		    # set PORTC output
    not     t0, zero		    # t0=0xFFFFFFFF
    sw	    t0, TRISB		    # set PORTB input
  
    //set inital mode (both blink every 0.5 seconds)
    li	    t0, _PORTA_RA0_MASK	    ## t0 = 0x00000001 --> control LED1
    li	    t1, _PORTC_RC9_MASK	    ## t1 = 0x00000200 --> control LED2
    sw	    t0, LATASET
    sw	    t1, LATCSET
    // set up registers to track mode of operation and determine state
    add	    t7,zero, zero	    ## t7 register will be used to track the mode
    add	    t8, zero, zero	    ## t8 will be used to track whether in 
				    ## paused state or not
    j	    invertblink	 
   nop

pollS1:
    lw	    t2, PORTB		    ## Read Port B
    
    andi    t3, t2, _PORTB_RB7_MASK ## Check S1
    bne	    t3, zero, copyS1	    ## If button not pressed (RB7 = 1), 
    nop				    ##    copy state and check S2
    beq	    t3, t5, pollS2	    ## If button pressed but hasn't changed
    nop				    ##    check state of S2
    
    ## Must be a new button press--wait ~0.5 sec and check it again
    jal	    delay		    ## Call debounce function for delay
    nop
    
    ## Check if button still pressed
    lw	    t2, PORTB		    
    andi    t3, t2, _PORTB_RB7_MASK 
    bne	    t3, zero, copyS1
    nop
    // pause or play depending on the vaue of register 8
    // if not paused, set (t8 = 1)
    bne	    t8, zero, unfreeze	    
    nop
    addi    t8, t8, 1
    j	    copyS1
    nop
    // if paused, set (t8 = 0)
unfreeze:
    add	    t8, zero, zero
copyS1:
    add	    t5, t3, zero	    ## t5 = saved state of S1
    bne	    t8, zero, pollS1	    ## check if in paused state or not
				    ## keep polling S1 if in paused state (t8 = 1)
    nop
pollS2:
    lw	    t2, PORTB
    andi    t4, t2, _PORTB_RB13_MASK ## Check S2
    bne	    t4, zero, copyS2	    ## If button not pressed (RB13 = 1), 
    nop				    ##    copy state and go back to checking S1
    beq	    t4, t6, pollS1	    ## If button pressed but hasn't changed
				    ##    check state of S1

    ## Must be a new button press--wait ~0.5 sec and check it again
    jal	    delay		    ## Call debounce function for delay
    nop
    
    ## Check if button still pressed
    lw	    t2, PORTB		    
    andi    t4, t2, _PORTB_RB13_MASK 
    bne	    t4, zero, copyS2
    nop
    // check which mode to change to
    // mode (0x0000): both LEDs blinking simultanoeusly 
    // mode (0x0001): both LEDs blinking but alternating 
    // mode (0x0002): LED 1 blinking only 
    // mode (0x0003): LED 2 blinking only 
check:
    addi    t3, t7, -3		    ## check if the max mode has been reached
    beq	    t3, zero, reset	    ## reset to the base mode  
    nop
    addi    t7, t7, 0x0001	    ## increment to the next mode0
    j	    checkconfig
    nop
reset:
    add	    t7, zero, zero
    // check how to cofigure if both LEDs are going to blink
checkconfig:
    beq	    t7, zero, configBoth
    nop
    addi    t3, zero, 0x0001
    beq	    t3, t7, configAlternate
    nop
    j	    copyS2
    // configuration for simultaneous duo-blink
configBoth:
    sw	    t0, LATASET
    sw	    t1, LATCSET  
    j	    copyS2
    nop
    // cofiguration for alternating blink
configAlternate:
    sw	    t0, LATASET
    sw	    t1, LATCCLR
copyS2:
    add	    t6, t4, zero	    ## t6 = saved state of S2
    
// RUN
run:
    addi    t3,t7, -3		    ## check if LED2 blink only
    beq	    t3, zero, RC9blink
    nop
    addi    t3,t7, -2		    ## check if LED1 blink only
    beq	    t3, zero, RA0blink
    nop
invertblink:
// blink both or alternate
    sw	    t0, LATAINV		    				   
    sw	    t1, LATCINV
    j	    delayTwo
    nop
// blink LED1 only
RA0blink:
    sw	    t0, LATAINV
    sw	    t1, LATCCLR
    j	    delayTwo
    nop
// blink LED2 only
RC9blink:
    sw	    t1, LATCINV
    sw	    t0, LATACLR
    j	    delayTwo
    nop
// blink delay
delayTwo:
    li	    t3, 1333333
wait:
    addi    t3, t3, -1
    bne	    t3, zero, wait
    nop
    j	    pollS1
    nop
// debouncing delay
delay:
    add	    s0, zero, t7
    li	    t7, 0x61A8		    ## Set delay counter to 0x61A8 = 25,000
				    ## Since loop body has 3 instructions,
				    ##   loop takes 25,000 * 3 = 75,000
				    ##   cycles
				    ## Remaining 3 instructions take 3 cycles
				    ##  ~75,000 cycles / 8 MHz clock ~ 0.009375 sec delay
loop:
    addi    t7, t7, -1		    ## Decrement counter
    bne	    t7, zero, loop	    ##  and continue doing that until we hit 0
    nop				    ## NOTE: This function originally branched
				    ##   to "done" if t7 != zero, which means
				    ##   the delay loop was really no loop at all!
    add	    t7, s0, zero
    jr	    ra
    nop
    
.end main