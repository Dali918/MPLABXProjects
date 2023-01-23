## Dalitso Banda
## EECE.3170: Microprocessors I
## UMass Lowell
## Instructor: M. Geiger
## HW 5
           
    
    
// Including xc.h allows use of SFR names, bit masks, etc.

    
    .globl  __vector_dispatch_9    ## Port B change notification = vector #9
    .section .vector_9, code, keep
    .align 2
    .set nomips16
    .ent __vector_dispatch_9
__vector_dispatch_9:
    j  isrvector9	    ## Jump to actual ISR code, which is in text section
    nop
    .end __vector_dispatch_9
    .size __vector_dispatch_9, .-__vector_dispatch_9
    
    .globl  __vector_dispatch_11    ## Timer1 interrupt source vector = 11
    .section .vector_11, code, keep
    .align 2
    .set nomips16
    .ent __vector_dispatch_11
__vector_dispatch_11:
    j  isrvector11	    ## Jump to actual ISR code, which is in text section
    nop
    .end __vector_dispatch_11
    .size __vector_dispatch_11, .-__vector_dispatch_11
    
    .text		## Text section contains code
    .set noreorder	## Disable instruction reordering
    .globl	main	## define main as a global entity
    .ent	main
#include <xc.h>
main:
    
    // Configure port A and C for output
    sw	    zero, ANSELA	    # set PORTA as a digital
    sw	    zero, ANSELC	    # set PORTC as digital
    sw	    zero, TRISA		    # set PORTA as output
    sw	    zero, TRISC		    # set PORTC as output
    
    // Configure port B
    sw	    zero, ANSELB	    # set PORTB as digital
    not     t0, zero		    # t0=0xFFFFFFFF
    sw	    t0, TRISB		    # set PORTB as input
   
    // Configure Timer 1
    sw	    zero, T1CON		    ## Clear T1CON--disables timer to allow setup
    ori	    t1, zero, 0x0FFF	    ## Set t1 = 0x0FFF = initial PR1 value
    sw	    t1, PR1		    ##   (maximum possible initial clock period--4,095 cycles)
    
    ## Prescale clock
    li	    t3, _T1CON_TCKPS_MASK  ## Prescale by factor of 256 (TCKPS = 11)
    sw	    t3, T1CONSET	    
   
    //confugure interrupt priority
    lui	    t3, 0x0001			## Want INTCON bit 16 (VS<0>) = 1
					##   so vectors 8 bytes apart
    ori	    t3, t3, _INTCON_MVEC_MASK   ## Enable multivectored interrupt mode
    sw	    t3, INTCON
    and	    t3, t3, zero		## clear register t3 
    li	    t3, _IPC2_T1IP_MASK		## Set Timer 1 interrupt priority to level 7
    ori	    t3, t3, _IPC2_CNBIP_MASK    ## Set change notification Port B interrupt priority level to 7
    sw	    t3, IPC2			## Implicitly sets subpriority level to 0 with the change notification for 
					## PORTB having higher natural priority
  
    //configure interrupt enable
    and	    t3, t3, zero		## clear register t3 
    li	    t3, _IEC0_T1IE_MASK		## enable Timer1 interrupts
    ori	    t3, t3,_IEC0_CNBIE_MASK	## enable PORTB change notification interrupts
    sw	    t3, IEC0			
    ei					## Enable interrupts globally
    
    //cofigure input button change notification
    li	    t3, _PORTB_RB7_MASK		## Set bits in CNEN1B = 1 and CNEN0B = 0
    ori	    t3, t3, _PORTB_RB13_MASK    ## corresponding to switch positions
					## Will detect falling edges on these pins 
    sw	    t3, CNEN1B			##
    sw	    zero, CNEN0B		## 
    
   
    li	    t3, _CNCONB_ON_MASK		    ## Enables Port B change notification
    ori	    t3, t3, _CNCONB_CNSTYLE_MASK    ## Enables edge detection
    sw	    t3, CNCONB
    
    
    li	    t3, _T1CON_TON_MASK		## Enable Timer 1 by setting "ON" bit in T1CON
    sw	    t3, T1CONSET
mainloop:
    j mainloop
    nop

    .end main
    .globl delay
    .ent  delay
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
    
    
    .globl isrvector11
    .ent isrvector11
isrvector11:
    li	    t4, _IFS0_T1IF_MASK    
    sw	    t4, IFS0CLR		    ## Clear T1IF in software!
    
    li	    t4, _PORTA_RA0_MASK	    ## Load the controlling mask for LED 1
    lw	    t5, PORTA
    and	    t4, t4, t5		    ## get the current state of the LED1 (ON/OFF)
    
    li	    t5, _PORTC_RC9_MASK	    ## Load the controlling mask for LED 2
    lw	    t6, PORTC
    and	    t5, t5, t6		    ## get the current state of LED 2 (ON/OFF)
   
    or	    t6, t5, t4		    ## will branch when both lights are off
    beq	    zero, t6, bothOff
    nop
    
    and	    t6, t5, t4		    ## check if both LEDs are on
    bne	    zero, t6, bothOn	    
    nop
    
    beq	    zero, t5, LED2OFF	    ## check if LED 2 is off
    nop
    li	    t4, _PORTA_RA0_MASK	    ## Load the controlling mask for LED 1
    li	    t5, _PORTC_RC9_MASK	    ## Load the controlling mask for LED 2
    sw	    t4, LATAINV		    ## switch the LEDs (01>>10)
    sw	    t5, LATCINV
    j	    exit
    nop
    
bothOff:
     li	    t5, _PORTC_RC9_MASK	    ## Load the controlling mask for LED 2
     sw	    t5, LATCINV		    ## turn LED2 on (00 >> 01)
     j	    exit
     nop
bothOn:
    li	    t4, _PORTA_RA0_MASK	    ## Load the controlling mask for LED 1
    li	    t5, _PORTC_RC9_MASK	    ## Load the controlling mask for LED 2
    sw	    t4, LATAINV		    ## switch the LEDs
    sw	    t5, LATCINV		    ## (11>>00)
    j       exit
    nop
LED2OFF:
    li	    t5, _PORTC_RC9_MASK	    ## Load the controlling mask for LED 2
    sw	    t5, LATCINV		    ## flip LED2 (10>>11) 
exit:   
    eret		    ## Return from interrupt
    .end isrvector11

    .globl isrvector9
    .ent isrvector9
isrvector9:
    li	    t0, _PORTB_RB7_MASK    ## t0 = 0x00000080 --> mask for S1
    li	    t1, _PORTB_RB13_MASK	    ## t1 = 0x00002000 --> mask for S2
    
    // Check S1
    lw	    t8, CNFB
    and	    t9, t8, t0		    ##
    beq	    t9, zero, checkS2	    ## If bit 7 = 0, S1 wasn't pressed
    nop
    
    // S1 pressed--clear flag, then debounce and toggle if actually pressed
    sw	    t0, CNFBCLR		    ## Clear flag for S1
    jal	    delay		    ## Delay to debounce
    nop
    lw	    t2, PORTB		    
    and	    t2, t2, t0		    ## Is button still pressed?
    bne	    t2, zero, checkS2	    ## If not, leave LED alone and check S2
    nop
    
    //code to deal double the period appropriately or set to min period
    lw	    t2, PR1		    ## load the current timer period
    ori	    t3, zero, 0xFFF0	    ## load the maximum delay allowed
    sub	    t3, t3, t2		    ## if maxdelay - currentperiod > 0
				    ## current period = current period * 2
    bne	    t3, zero, double
    nop
    ori	    t2,	zero, 0x0FFF	    ## if max delay reached set period to the 
				    ## initial minimum delay
    sw	    t2, PR1
    j	    intdone		    ## jump to ISR return 
    nop
double:
   sll	    t2, t2, 1		    ## shift left by one to multiply by 2
   sw	    t2, PR1		    ## update the period
   j	    intdone		    ## jump to ISR return
   nop
    // Check S2
checkS2:
    and	    t9, t8, t1
    beq	    t9, zero, intdone	    ## If bit 13 = 0, S2 wasn't pressed
    nop
    
    // S2 pressed--clear flag, then debounce and toggle if actually pressed
    sw	    t1, CNFBCLR		    ## Clear flag for S2
    jal	    delay		    ## Delay to debounce
    nop
    lw	    t2, PORTB		    
    and	    t2, t2, t1		    ## Is button still pressed?
    bne	    t2, zero, intdone	    ## If not, leave LED alone S2 wasn't pressed
    nop
    // code to half the period or set to max period
    lw	    t2, PR1		    ## load the current period
    ori     t3, zero,0x0FFF	    ## load the minimum delay
    sub	    t3, t2, t3		    ## if current period - min period > 0
				    ## branch to code that divides by 2
    bne	    t3, zero, half	    ## 
    nop
    ori	    t2,	zero, 0xFFF0	    ## if current period == min delay
				    ## current period = max delay
    sw	    t2, PR1
    j intdone
    nop
half:
   srl	    t2, t2, 1
   sw	    t2, PR1
intdone:
    li	    t3, _IFS0_CNBIF_MASK    ## Clear Port B change notification flag
    sw	    t3, IFS0CLR		    ##    in IFS0
    eret		    ## Return from interrupt
    .end isrvector9