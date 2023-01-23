## EECE.3170: Microprocessors I
## UMass Lowell
## Instructor: M. Geiger
## timerTest.S: in-class example to demonstrate PIC timer basics
##     Basically same as portTest1.S but using timer-based delay loop
           
    .text		## Text section contains code
    .set noreorder	## Disable instruction reordering
    .globl main		## Define main label as a global entity
    .ent main		##   and an entry point    
    
// Including xc.h allows use of SFR names, bit masks, etc.
#include <xc.h>
    
main:
    
    // Configure port A for output
    sw	    zero, TRISA		    ## TRISA = 0  --> all PORTA bits = output
    sw	    zero, ANSELA	    ## ANSELA = 0 --> all PORTA bits digital
    li	    t0, _PORTA_RA0_MASK	    ## $t0 = 0x00000001    
    sw	    t0, LATASET		    ## Set Port A, bit 0 (turn LED1 on)
    
    // Configure Timer 1
    sw	    zero, T1CON		    ## Clear T1CON--disables timer to allow setup
    
    ori	    t1, zero, 0xFFFF	    ## Set t1 = 0xFFFF = initial PR1 value
    sw	    t1, PR1		    ##   (maximum possible clock period--65,535 cycles)
    
    li	    t2, _IFS0_T1IF_MASK	    ## t2 = bit mask for checking Timer 1 interrupt flag
    
    ## Prescale clock
    li	    t3, _T1CON_TCKPS1_MASK  ## Prescale by factor of 64 (TCKPS = 10)
    sw	    t3, T1CONSET
    
    li	    t3, _T1CON_TON_MASK	    ## Enable Timer 1 by setting "ON" bit in T1CON
    sw	    t3, T1CONSET
    
poll:   
    lw	    s0, IFS0		    ## Read interrupt flags register
    and	    s0, s0, t2		    ## Check T1IF (Timer 1 interrupt flag)
    beq	    s0, zero, poll	    ## If not set, return to start of polling loop
    nop
    
    ## Once you get here, T1IF is set, which means timer count matches PR1
    sw	    t2, IFS0CLR		    ## Must clear T1IF in software!!!
    sw	    t0, LATAINV		    ## Flip LED1
    
    j	    poll		    ## Reset delay counter and start again
    nop

    .end main