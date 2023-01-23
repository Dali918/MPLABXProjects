/**** REPLACE THIS COMMENT WITH A COMMENT CONTAINING YOUR NAME ****/
## Dalitso Banda    
## EECE.3170: Microprocessors I
## UMass Lowell
## Instructor: M. Geiger
## finalExam_p1.S: first programming problem on Fall 2020 final exam
/*****
    MODIFICATIONS TO MAKE:
     Currently, the program blinks both LEDs at the same time, and it's doing
     so at such a fast rate that you can't tell they're blinking--they appear
     to always be on. 

     You must change this program so that:
     
     - The time between Timer 1 interrupts, and therefore changes in the state
        of the LEDs, is approximately 0.75 sec.
     
     - The LEDs cycle between 8 states, returning to state 1 after leaving state 8:
	  1. LED2 on
          2. Both LEDs off
	  3. LED1 on
	  4. Both LEDs off
	  5. Both LEDs on
	  6. Both LEDs off
	  7. LED1 on
	  8. Both LEDs off
*****/
    
// Including xc.h allows use of SFR names, bit masks, etc.
#include <xc.h>

    // Interrupt vector setup    
    .globl  __vector_dispatch_11    ## Timer 1 interrupt = vector #11
    .section .vector_11, code, keep
    .align 2
    .set nomips16
    .ent __vector_dispatch_11
__vector_dispatch_11:
    j  isrvector11	    ## Jump to actual ISR code, which is in text section
    nop
    .end __vector_dispatch_11
    .size __vector_dispatch_11, .-__vector_dispatch_11
    
    // Start of text section       
    .text		## Text section contains code
    .set noreorder	## Disable instruction reordering
    .globl main		## Define main label as a global entity
    .ent main		##   and an entry point    

main:
    
    // Configure port A for output
    sw	    zero, TRISA		    ## TRISA = 0  --> all PORTA bits = output
    sw	    zero, ANSELA	    ## ANSELA = 0 --> all PORTA bits digital
    sw	    zero, TRISC		    ## TRISC = 0  --> all PORTC bits = output
    sw	    zero, ANSELC	    ## ANSELC = 0 --> all PORTC bits digital
    
    // Configure Timer 1
    sw	    zero, T1CON		    ## Clear T1CON--disables timer to allow setup
    ori	    t1, zero, 23438	    ## period will produce a delay of approximately 
				    ## 0.75s when prescaled by factor of 256
    sw	    t1, PR1
    li	    t1, _T1CON_TCKPS_MASK  ## Prescale by factor of 256 (TCKPS = 11)
    sw	    t1, T1CONSET
    /*** 
     Desired delay is 0.75 s between interrupts
     ADD TIMER SETTINGS TO GET THE DESIRED DELAY
     ***/
    
    // Configure interrupts
    lui	    t3, 0x0001			## Want INTCON bit 16 (VS<0>) = 1
					##   so vectors 8 bytes apart
    ori	    t3, t3, _INTCON_MVEC_MASK   ## Enable multivectored interrupt mode
    sw	    t3, INTCON
    
    li	    t3, _IPC2_T1IP_MASK	    ## Set T1 interrupt priority level to 7
    sw	    t3, IPC2		    ## Implicitly sets subpriority level to 0
    
    li	    t2, _IFS0_T1IF_MASK	    ## t2 = bit mask for checking Timer 1 interrupt flag
    sw	    t2, IEC0		    ## Enable Timer 1 interrupts (uses
				    ##   same bit mask as T1 interrupt flag)
				    
    ei				    ## Enable interrupts globally
				    
    li	    t3, _T1CON_TON_MASK	    ## Enable Timer 1 by setting "ON" bit in T1CON
    sw	    t3, T1CONSET
    
    add	    t3, zero, zero
   
    // Main loop--whole lotta nothing, just waiting for interrupt
mainloop:
    j	mainloop
    nop
    .end main
    
    // Handle Timer1 interrupt--clear interrupt flag and toggle LED
    .global isrvector11
    .ent isrvector11
isrvector11:
    li	    t2, _IFS0_T1IF_MASK    
    sw	    t2, IFS0CLR		    ## Clear T1IF in software!
      
    /*** MODIFY THE LED BEHAVIOR TO IMPLEMENT THE 8 STATES DESCRIBED ABOVE ***/
    
    li	    t0, _PORTA_RA0_MASK	    ## LED1 mask
    li	    t1, _PORTC_RC9_MASK	    ## LED2 mask
    
    // check whether to turn off both LEDs 
    bne	    t5, zero, clear	    # check clear flag, stored in t5.
    nop
    
    // check how to turn on LEDs
modify:
    addi    t5, t5, 0x0001	    # set flag to turn off both in the next service
    addi    t4, t3, -1		    # check to turn on LED1 only
    beq	    t4, zero, led1On
    nop
    addi    t4, t3, -3
    beq	    t4, zero, reset	    
    nop
    
    addi    t4, t3, -2		    # check to turn on both LEDs on
    beq	    t4, zero, bothOn
    nop
    // LED2 on (initial state)
    sw	    t0, LATACLR		    # initial state 
    sw	    t1, LATCSET
    j	    intdone
    nop
    
    // LED 1 on
reset:
   li	    t3,  -1	    # reset the mode tracker if necessary 
			    # (will reset to 0 in the next service when turning both off)
led1On:
    sw	    t0, LATASET
    sw	    t1, LATCCLR
    j	    intdone	    
    nop
    
    // both LEDs on
bothOn:
    sw	    t0, LATASET
    sw	    t1, LATCSET
    j	    intdone
    nop
    
    // both LEDS off
clear:
    add	    t5, zero, zero	    # reset flag to modify LEDs in the next service
    addi    t3, t3, 0x0001	    # increment the 'on' state tracker
    sw	    t0, LATACLR		    # clear both LEDs
    sw	    t1, LATCCLR 
    // return from isr
intdone:
    eret		    ## Return from interrupt
    .end isrvector11
    
// Thanks for a great semester!