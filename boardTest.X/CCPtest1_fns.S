## EECE.3170: Microprocessors I
## UMass Lowell
## Instructor: M. Geiger
## CCPTest1_fns.S: in-class example to demonstrate CCP module output mode
##   Functions file contains useful functions & ISR
##     Uses potentiometer input to drive intensity of RGB LED on board
##     Reuses some code from out of box demo, although A/D conversions 
##        are interrupt-driven (like ADCTest2.S)
  
// Including xc.h allows use of SFR names, bit masks, etc.
#include <xc.h>
    
    // Continuation of text section           
    .text		## Text section contains code
    .set noreorder	## Disable instruction reordering
    
    // Delay loop for switch debouncing
    .global delay
    .ent delay
delay:
    li	    t7, 0x61A8		    ## Set delay counter to 0x61A8 = 25,000
				    ## Since loop body has 3 instructions,
				    ##   loop takes 25,000 * 3 = 75,000
				    ##   cycles
				    ## Remaining 3 instructions take 3 cycles
				    ##  ~75,000 cycles / 8 MHz clock ~ 0.009375 sec delay
loop:
    addi    t7, t7, -1		    ## Decrement counter
    bne	    t7, zero, loop	    ##  and continue doing that until we hit 0
    nop				    
    jr	    ra
    nop

    .end delay
    
    // Handle Port B change interrupt--check S1 and switch LED state accordingly
    .global isrvector9
    .ent isrvector9
isrvector9:   
    li	    t4, _PORTB_RB7_MASK	    ## t4 = 0x00000080 --> mask for S1
    
    // Check S1
    lw	    t8, CNFB
    and	    t9, t8, t4
    beq	    t9, zero, intdone	    ## If bit 7 = 0, S1 wasn't pressed
    nop
    
    // S1 pressed--clear flag, then debounce and toggle if actually pressed
    sw	    t4, CNFBCLR		    ## Clear flag for S1
    jal	    delay		    ## Delay to debounce
    nop
    lw	    t2, PORTB		    
    and	    t2, t2, t4		    ## Is button still pressed?
    bne	    t2, zero, intdone	    ## If not, leave LED alone and check S2
    nop

    // Update LED state control --> should be 0, 1, or 2
    addi    s7, s7, 1
    slti    t9, s7, 3		    ## t9 == 1 if s7 < 3
    bne	    t9, zero, intdone
    nop
    
    add	    s7, zero, zero	    ## If you get here, s7 >= 3 (should just be == 3)
				    ##   so reset it to 0
    
intdone:
    li	    t3, _IFS0_CNBIF_MASK    ## Clear Port B change notification flag
    sw	    t3, IFS0CLR		    ##    in IFS0
    eret		    ## Return from interrupt
    .end isrvector9
    
    
    // Handle ADC interrupt--clear interrupt flag and update LEDs based on conversion result
    .global isrvector15
    .ent isrvector15
isrvector15:
    li	    t1, _IFS0_AD1IF_MASK    
    sw	    t1, IFS0CLR		    ## Clear AD1IF in software!
    
    li	    t0, _PORTA_RA0_MASK
    sw	    t0, LATASET
    
    lw	    t1, ADC1BUF0	    ## Read ADC result into t1
    
    // Based on LED state control, update one of CCP RB registers,
    //    which will change width of pulse written to that channel &
    //    therefore intensity of that color in LED output
    slti    t5, s7, 1		    ## If s7 < 1, must be 0
    beq	    t5, zero, chkGRN	    ## If t5 == 0, s7 >= 1
    nop				    ##    so check other states
    
    // s7 == 0 --> "red"
    //   So, update CCP1RB with ADC result
    sw	    t1, CCP1RB
    j	    int15done
    nop
    
chkGRN:
    slti    t5, s7, 2		    ## If s7 < 2, must be 1
    beq	    t5, zero, isBLUE	    ## If t5 == 0, s7 must be 2
    nop				    ##    so handle "blue" state
    
    // s7 == 1 --> "green"
    //   So, update CCP2RB with ADC result
    sw	    t1, CCP2RB
    j	    int15done
    nop
    
isBLUE:
    // s7 == 2 --> "blue"
    //   So, update CCP3RB with ADC result
    sw	    t1, CCP3RB
    
int15done:    
    eret		    ## Return from interrupt
    .end isrvector15          