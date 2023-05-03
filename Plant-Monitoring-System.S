;------------------------
; Assembly Code
;------------------------
#define __SFR_OFFSET 0x00
#include "avr/io.h"
;------------------------
.global main
;=================================================================
main:
;------------
    LDI R17, 0xFF
    OUT DDRC, R17 ;set port C for o/p
    OUT DDRD, R17 ;set port D for o/p
;-----------------------------------------------------------------
agn:
    RCALL delay_2s ;wait 2s for DHT11 to get ready
;-----------------------------------------------------------------
;send start signal
;------------
    SBI DDRB, 1 ;pin PB0 as o/p
    CBI PORTB, 1 ;first, send low pulse
    RCALL delay_20ms ;for 20ms
    SBI PORTB, 1 ;then send high pulse
;-----------------------------------------------------------------
;wait for response signal
;---------------
    CBI DDRB, 1 ;pin PB0 as i/p
    w1: SBIC PINB, 1
    RJMP w1 ;wait for DHT11 low pulse
    w2: SBIS PINB, 1
    RJMP w2 ;wait for DHT11 high pulse
    w3: SBIC PINB, 1
    RJMP w3 ;wait for DHT11 low pulse
;-----------------------------------------------------------------
    RCALL DHT11_reading ;read humidity (1st byte of 40-bit data)
    MOV R19, R18
    RCALL DHT11_reading
    RCALL DHT11_reading ;read temp (3rd byte of 40-bit data)
;-----------------------------------------------------------------
    OUT PORTD, R19 ;o/p temp byte to port C
    OUT PORTC, R18 ;o/p humidity byte to port D
    RJMP agn ;go back & get another sensor reading
;=================================================================
DHT11_reading:
    LDI R17, 8 ;set counter for receiving 8 bits
    CLR R18 ;clear data register
;-------------------------------------------------------
w4: 
    SBIS PINB, 1
    RJMP w4 ;detect data bit (high pulse)
    RCALL delay_timer0 ;wait 50us & then check bit value
;-------------------------------------------------------
    SBIS PINB, 1 ;if received bit=1, skip next inst
    RJMP skp ;else, received bit=0, jump to skp
    SEC ;set carry flag (C=1)
    ROL R18 ;shift in 1 into LSB data register
    RJMP w5 ;jump & wait for low pulse
    skp:LSL R18 ;shift in 0 into LSB data register
;-------------------------------------------------------
w5: 
    SBIC PINB, 1
    RJMP w5 ;wait for DHT11 low pulse
;-------------------------------------------------------
    DEC R17 ;decrement counter
    BRNE w4 ;go back & detect next bit
    RET ;return to calling subroutine
;=================================================================
;delay subroutines
;=================================================================
delay_20ms: ;delay 20ms
    LDI R21, 255
    l3: LDI R22, 210
    l4: LDI R23, 2
    l5: DEC R23
    BRNE l5
    DEC R22
    BRNE l4
    DEC R21
    BRNE l3
    RET
;-----------------------------------------------------------------
delay_2s: ;delay 2s
    LDI R21, 255
    l6: LDI R22, 255
    l7: LDI R23, 164
    l8: DEC R23
    BRNE l8
    DEC R22
    BRNE l7
    DEC R21
    BRNE l6
    RET
;===============================================================
delay_timer0: ;50 usec delay via Timer 0
;---------------------------------------------------------
    CLR R20
    OUT TCNT0, R20 ;initialize timer0 with count=0
    LDI R20, 100
    OUT OCR0A, R20 ;OCR0 = 100
    LDI R20, 0b00001010
    OUT TCCR0B, R20 ;timer0: CTC mode, prescaler 8
;---------------------------------------------------------
l2: 
    IN R20, TIFR0 ;get TIFR0 byte & check
    SBRS R20, OCF0A ;if OCF0=1, skip next instruction
    RJMP l2 ;else, loop back & check OCF0 flag
;---------------------------------------------------------
    CLR R20
    OUT TCCR0B, R20 ;stop timer0
;---------------------------------------------------------
    LDI R20, (1<<OCF0A)
    OUT TIFR0, R20 ;clear OCF0 flag
    RET