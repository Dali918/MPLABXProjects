## EECE.3170: Microprocessors I
## UMass Lowell
## Instructor: M. Geiger
## CCPTest1.S: in-class example to demonstrate CCP module output mode
##     Uses potentiometer input to drive intensity of RGB LED on board
##     Reuses some code from out of box demo, although A/D conversions 
##        are interrupt-driven (like ADCTest2.S)
  
// Including xc.h allows use of SFR names, bit masks, etc.
#include <xc.h>

    // Interrupt vector setup    
    // Port B change notification
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
    
    // ADC interrupt
    .globl  __vector_dispatch_15    ## ADC interrupt = vector #15
    .section .vector_15, code, keep
    .align 2
    .set nomips16
    .ent __vector_dispatch_15
__vector_dispatch_15:
    j  isrvector15	    ## Jump to actual ISR code, which is in text section
    nop
    .end __vector_dispatch_15
    .size __vector_dispatch_15, .-__vector_dispatch_15
    
    // Start of text section           
    .text		## Text section contains code
    .set noreorder	## Disable instruction reordering
    .globl main		## Define main label as a global entity
    .ent main		##   and an entry point 
    
main:
    /* Configure I/O ports--RGB LED inputs on Port A & B; 
          analog input on Port B, pin 3;
	  digital input (S1) on Port B, pin 7*/
    sw	    zero, TRISA		    ## TRISA = 0  --> all PORTA bits = output
    sw	    zero, ANSELA	    ## ANSELA = 0 --> all PORTA bits digital
    li	    t0, _PORTB_RB3_MASK
    ori	    t0, t0, _PORTB_RB7_MASK
    sw	    t0, TRISB		    ## TRISB = 0x00000088 --> pins 3, 7 input, others output
    sw	    t0, ANSELB		    ## ANSELB = 0x00000008 --> pin 3 analog, pin 7 digital
    
    /*****************************
     ADC setup from PIC32MM out of box demo (adc.c) modified for autosampling: 
        AD1CON1bits.FORM = 0b00;
        AD1CON1bits.SSRC = 0x7;	    (Internal counter ends sampling & starts conversion)
	AD1CON1bits.ASAM = 1;	    (Automatically start sampling once conversion done)
        AD1CON2bits.VCFG = 0x0 ;
        AD1CON2bits.SMPI = 0x0;     
        AD1CON3bits.ADCS = 0xFF ;   (T_AD = 510 * T_SRC (slowest possible A/D conversion clock)
        AD1CON3bits.SAMC = 0b10000; (auto-sample time = 16 * T_AD)
        AD1CON1bits.ON = 1 ;
    ******************************/
    li	    s0, _AD1CON1_ASAM_MASK  ## Set automatic sampling bit
    ori	    s0, s0, 0x70	    ## Set SSRC field = 0x7 for autoconversion after internal timer
    sw	    s0, AD1CON1		    ## Still using 10-bit conversion mode
				    ##   but now using autosampling

    sw	    zero, AD1CON2	    ## Clear all bits (key bits: VCFG for Vdd/Vss as reference
				    ##    SMPI for 1 sample/interrupt)
    li	    s0, _AD1CON3_ADCS_MASK  ## ADCS = 0xFF --> T_AD = 510 * T_SRC (slowest possible A/D conversion clock)
    ori	    s0, s0, 0x1000	    ## SAMC = 0b10000 --> auto-sample time = 16 * T_AD = 8,160 * T_SRC
				    ##   T_SRC = peripheral bus clock
    sw	    s0, AD1CON3

    li	    s0, 11		    ## Potentiometer is connected to AN11
    sw	    s0, AD1CHS		    ##   so set AD1CHS = 11

    /*********************************
     RGB LED setup
        "Red" channel = RA3    --> shared with OCM1D (output D from CCP module 1)
        "Green" channel = RB12 --> not shared with any OCM output,
				     but it is shared with RP12 (reconfigurable peripheral pin 12)
				     so we can map output of CCM module 2 to that pin
        "Blue" channel = RA2   --> shared with OCM1C (output C from CCP module 1),
                                     but CCP module 1 is driving red channel;
                                     This pin is also shared with RP3 (reconfigurable peripheral pin 3)
                                     so we can map output of CCM module 3 to that pin
    **********************************/
    
    // First, set up remappable peripheral pins
    lui	    t3, 0x0600		    ## Set RPOR2 = 0x06000000
    sw	    t3, RPOR2		    ##   which maps CCP module 2 output to pin RP12 (RB12; green output)
    
    lui	    t3, 0x0007		    ## Set RPOR0 = 0x00070000
    sw	    t3, RPOR0		    ##   which maps CCP module 3 output to pin RP3 (RA2; blue output)
    
    // Next, set up CCP modules
    // CCP1: red output
    li	    t3, 0x4		    ## Set CCP1CON1 MOD field = 4 --> dual edge compare
    sw	    t3, CCP1CON1
    
    li	    t3, _CCP1CON2_OCDEN_MASK	## Set CCP1CON2 OCDEN bit --> enable output OCM1D to drive red output
    sw	    t3, CCP1CON2
    
    sw	    zero, CCP1CON3
    sw	    zero, CCP1TMR
    sw	    zero, CCP1RA	    ## Output pulse width initially 0; will update CCP1RB with 
    sw	    zero, CCP1RB	    ##   potentiometer value when in "red" mode
    
    li	    t3, 0x3FF		    ## Set timer period = 0x3FF, which matches max
    sw	    t3, CCP1PR		    ##   value read from potentiometer

    li	    t3, _CCP1CON1_ON_MASK   ## Enable CCP1
    sw	    t3, CCP1CON1SET	    
    
    // CCP2: green output
    li	    t3, 0x4		    ## Set CCP2CON1 MOD field = 4 --> dual edge compare
    sw	    t3, CCP2CON1
    
    li	    t3, _CCP2CON2_OCAEN_MASK	## Set CCP2CON2 OCAEN bit --> enable output OCM2A to drive red output
    sw	    t3, CCP2CON2
    
    sw	    zero, CCP2CON3
    sw	    zero, CCP2TMR
    sw	    zero, CCP2RA	    ## Output pulse width initially 0; will update CCP2RB with 
    sw	    zero, CCP2RB	    ##   potentiometer value when in "green" mode
    
    li	    t3, 0x3FF		    ## Set timer period = 0x3FF, which matches max
    sw	    t3, CCP2PR		    ##   value read from potentiometer

    li	    t3, _CCP2CON1_ON_MASK   ## Enable CCP2
    sw	    t3, CCP2CON1SET	
    
    // CCP3: blue output
    li	    t3, 0x4		    ## Set CCP3CON1 MOD field = 4 --> dual edge compare
    sw	    t3, CCP3CON1
    
    li	    t3, _CCP3CON2_OCAEN_MASK	## Set CCP3CON2 OCAEN bit --> enable output OCM3A to drive red output
    sw	    t3, CCP3CON2
    
    sw	    zero, CCP3CON3
    sw	    zero, CCP3TMR
    sw	    zero, CCP3RA	    ## Output pulse width initially 0; will update CCP3RB with 
    sw	    zero, CCP3RB	    ##   potentiometer value when in "green" mode
    
    li	    t3, 0x3FF		    ## Set timer period = 0x3FF, which matches max
    sw	    t3, CCP3PR		    ##   value read from potentiometer

    li	    t3, _CCP3CON1_ON_MASK   ## Enable CCP3
    sw	    t3, CCP3CON1SET	
    
    /**** Configure interrupts ****/
    lui	    t3, 0x0001			## Want INTCON bit 16 (VS<0>) = 1
					##   so vectors 8 bytes apart
    ori	    t3, t3, _INTCON_MVEC_MASK   ## Enable multivectored interrupt mode
    sw	    t3, INTCON
    
    // ADC interrupt setup
    li	    t3, _IPC3_AD1IP_MASK    ## Set ADC interrupt priority level to 7
    sw	    t3, IPC3		    ## Implicitly sets subpriority level to 0
    
    li	    t2, _IEC0_AD1IE_MASK    ## Enable ADC interrupts
    sw	    t2, IEC0		    

    // Port B change interrupt setup (to detect S1 press)
    li	    t3, _IPC2_CNBIP_MASK    ## Set change notification Port B interrupt priority level to 7
    sw	    t3, IPC2		    ## Implicitly sets subpriority level to 0
				    ##   "Natural priority" puts buttons higher than ADC
				    ##   Change priority/subpriority if you want ADC higher

    li	    t3, _IEC0_CNBIE_MASK    ## Enable Port B change 
    sw	    t3, IEC0SET		    ##    notification interrupts

    li	    t4, _PORTB_RB7_MASK	    ## Set bit corresponding to S1 (port B, pin 7)
    sw	    t4, CNEN1B		    ##    in CNEN1B = 1 and CNEN0B = 0
    sw	    zero, CNEN0B	    ## Will detect falling edges on this pin
    
    li	    t3, _CNCONB_ON_MASK		    ## Enables Port B change notification
    ori	    t3, t3, _CNCONB_CNSTYLE_MASK    ## Enables edge detection
    sw	    t3, CNCONB
    
    // Global interrupt enable
    ei				    ## Enable interrupts globally
    
    // Enable ADC once interrupts set up
    li	    s0, _AD1CON1_ON_MASK
    sw	    s0, AD1CON1SET	    ## Enable ADC
    
    // Use s7 to track "button state":
    //   s7 = 0 --> potentiometer controls red LED input
    //   s7 = 1 --> potentiometer controls green LED input
    //   s7 = 2 --> potentiometer controls blue LED input
    add	    s7, zero, zero
        
    // Main loop does nothing, since ADC auto-samples
mainloop:
    j	    mainloop
    nop
    
    .end main