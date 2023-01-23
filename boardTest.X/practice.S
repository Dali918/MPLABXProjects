.text		## Text section contains code
.set noreorder	## Disable instruction reordering
.globl main		## Define main label as a global entity
.ent main
#include <xc.h>
main:
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
copyS2:
    addi    t7, zero, 1
    add	    t6, t4, zero	    ## t6 = saved state of S2
// check what the current mode is

// RUN
    addi    t5,t7, -3
    beq	    t5, zero, RC9blink
    nop
    addi    t5,t7, -2
    beq	    t5, zero, RA0blink
    nop
invertblink:
// blink both or alternate
    sw	    t0, LATAINV		    ## invert LED 1 and LED2				   
    sw	    t1, LATCINV
    j	    delayTwo
    nop
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
delayTwo:
    li	    t2, 800000
wait:
    addi    t2, t2, -1
    bne	    t2, zero, wait
    nop
    j	   copyS2
    nop   
    
spin:
    j spin
    nop
.end main