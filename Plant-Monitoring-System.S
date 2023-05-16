;------------------------
; Assembly Code
;------------------------
#define __SFR_OFFSET 0x00
#include "avr/io.h"
;------------------------
.global main


main:
  RCALL SPI_MAX7219_init
  LDI R16, 0xF0
  OUT DDRD, R16

;=================================================================
DHT11_sensor:
;-----------------------------------------------------------------
loop:
;--------------------------------------------------------
    CBI PORTD, 0
    CBI PORTD, 4
    CBI PORTD, 2
    CBI PORTD, 3
;--------------------------------------------------------
    RCALL MAX7219_clear
    RCALL MAX7219_disp_text_temp_humid
    RCALL delay_2s      ;wait 2s for DHT11 to get ready
;-----------------------------------------------------------------
;start_signal
;------------
    SBI   DDRD, 7       ;pin PD7 as o/p
    CBI   PORTD, 7      ;first, send low pulse
    RCALL delay_20ms    ;for 20ms
    SBI   PORTD, 7      ;then send high pulse
;-----------------------------------------------------------------
;responce signal
;---------------
    CBI   DDRD, 7       ;pin PD7 as i/p
w1: SBIC  PIND, 7
    RJMP  w1            ;wait for DHT11 low pulse
w2: SBIS  PIND, 7
    RJMP  w2            ;wait for DHT11 high pulse
w3: SBIC  PIND, 7
    RJMP  w3            ;wait for DHT11 low pulse
;-----------------------------------------------------------------
    RCALL DHT11_reading ;read humidity (1st byte of 40-bit data)
    MOV   R25, R24
    RCALL DHT11_reading
    RCALL DHT11_reading ;read temp (3rd byte of 40-bit data)
;-----------------------------------------------------------------
;convert temp & humidity bytes to decimal & display on MAX7219
;-------------------------------------------------------------
    MOV   R28, R24
    LDI   R29, 0x07
    LDI   R30, 0x06
    ;-------------------
    RCALL binary2decimal  ;temp in decimal
    ;-------------------
    MOV   R28, R25
    LDI   R29, 0x02
    LDI   R30, 0x01
    ;-------------------
    RCALL binary2decimal  ;humidity in decimal
    ;-------------------
    RCALL delay_5s
    RJMP YL39
    RJMP loop           ;go back & get another sensor reading


YL39:
  CLR R29               ;Menggunakan register R29
  SBIS PIND, 5          ;Cek YL39
  RJMP YL39out          ;jika dry pindah ke YL39out
  RCALL MAX7219_disp_text_moist ;ke disp moist
  RCALL delay_5s
  RJMP LDR

YL39out:
  INC R29               ;increment apabila dry
  ;SBI PORTD, 1          
  RCALL MAX7219_disp_text_dry ;ke disp dry
  RCALL delay_5s
  RJMP LDR              ;lompat ke ldr
  
LDR:
  SBIS PIND, 6          ;cek LDR
  RJMP LDRout           ;apabila dark pindah ke LDRout
  RCALL MAX7219_disp_text_light ;ke disp light
  RJMP BUZZ             ;lompat ke buzz

LDRout:
  INC R29               ;increment apabila dark
  ;SBI PORTD, 2        
  RCALL MAX7219_disp_text_dark  ;ke disp dark
  RJMP BUZZ             ;lompat ke buzz

BUZZ:
  MOV R30, R29
  CPI R30, 2            ;apabila dark dan dry
  BREQ BUZZout          ;ke buzzout
  CPI R30, 1            ;apabila salah satu dark atau dry
  BREQ Warning          ;ke warning
  RJMP Clear            ;ke clear
  
BUZZout:
  SBI PORTD, 3          ;set buzzer
  SBI PORTD, 2          ;set led merah     
  RCALL delay_5s
  RJMP loop

Warning: 
  SBI PORTD, 4          ;set led kuning
  RCALL delay_5s  
  RJMP loop

Clear:
  SBI PORTD, 0          ;set led hijau
  RCALL delay_5s
  RJMP loop

delay1_s:
    ldi  r18, 82
    ldi  r19, 43
    ldi  r20, 0
L1: dec  r20
    brne L1
    dec  r19
    brne L1
    dec  r18
    brne L1
    lpm
    nop
    RET


;=================================================================
DHT11_reading:
    LDI   R16, 8        ;set counter for receiving 8 bits
    CLR   R24           ;clear data register
    ;-------------------------------------------------------
w4: SBIS  PIND, 7
    RJMP  w4            ;detect data bit (high pulse)
    RCALL delay_timer0  ;wait 50us & then check bit value
    ;-------------------------------------------------------
    SBIS  PIND, 7       ;if received bit=1, skip next inst
    RJMP  skp           ;else, received bit=0, jump to skp
    SEC                 ;set carry flag (C=1)
    ROL   R24           ;shift in 1 into LSB data register
    RJMP  w5            ;jump & wait for low pulse
skp:LSL   R24           ;shift in 0 into LSB data register
    ;-------------------------------------------------------
w5: SBIC  PIND, 7
    RJMP  w5            ;wait for DHT11 low pulse
    ;-------------------------------------------------------
    DEC   R16           ;decrement counter
    BRNE  w4            ;go back & detect next bit
    RET                 ;return to calling subroutine
;=================================================================
;delay subroutines
;=================================================================
delay_20ms:             ;delay 20ms
    LDI   R21, 255
l3: LDI   R22, 210
l4: LDI   R23, 2
l5: DEC   R23
    BRNE  l5
    DEC   R22
    BRNE  l4
    DEC   R21
    BRNE  l3
    RET
;-----------------------------------------------------------------
delay_2s:               ;delay 2s
    LDI   R21, 255
l6: LDI   R22, 255
l7: LDI   R23, 164
l8: DEC   R23
    BRNE  l8
    DEC   R22
    BRNE  l7
    DEC   R21
    BRNE  l6
    RET
;===============================================================
delay_timer0:             ;50 usec delay via Timer 0
    ;---------------------------------------------------------
    CLR   R20
    OUT   TCNT0, R20      ;initialize timer0 with count=0
    LDI   R20, 100
    OUT   OCR0A, R20      ;OCR0 = 100
    LDI   R20, 0b00001010
    OUT   TCCR0B, R20     ;timer0: CTC mode, prescaler 64
    ;---------------------------------------------------------
l2: IN    R20, TIFR0      ;get TIFR0 byte & check
    SBRS  R20, OCF0A      ;if OCF0=1, skip next instruction
    RJMP  l2              ;else, loop back & check OCF0 flag
    ;---------------------------------------------------------
    CLR   R20
    OUT   TCCR0B, R20     ;stop timer0
    ;---------------------------------------------------------
    LDI   R20, (1<<OCF0A)
    OUT   TIFR0, R20      ;clear OCF0 flag
    RET
delay_5s:
    ldi  r21, 2
    ldi  r22, 150
    ldi  r23, 216
    ldi  r24, 9
l_5: dec  r24
    brne l_5
    dec  r23
    brne l_5
    dec  r22
    brne l_5
    dec  r21
    brne l_5
    RET
;===============================================================
;MAX7219 subroutines
;===============================================================
SPI_MAX7219_init:
;----------------
.equ  SCK, 5
.equ  MOSI, 3
.equ  SS, 2
;--------------------------------------------------------------
      LDI   R17, (1<<MOSI)|(1<<SCK)|(1<<SS)
      OUT   DDRB, R17       ;set MOSI, SCK, SS as o/p
      ;--------------------------------------------------------
      LDI   R17, (1<<SPE)|(1<<MSTR)|(1<<SPR0)
      OUT   SPCR, R17       ;enable SPI as master, fsck=fosc/16
      ;--------------------------------------------------------
      LDI   R17, 0x0A       ;set segment intensity (0 to 15)
      LDI   R18, 8          ;intensity level = 8
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x09       ;set decoding mode command
      LDI   R18, 0b01100011 ;decoding byte
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x0B       ;set scan limit command
      LDI   R18, 0x07       ;8 digits connected to MAX7219
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x0C       ;set turn ON/OFF command
      LDI   R18, 0x01       ;turn ON MAX7219
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      RET
;==============================================================
MAX7219_disp_text_temp_humid:
      LDI   R17, 0x09       ;set decoding mode command
      LDI   R18, 0b01100011 ;decoding byte
      RCALL send_bytes      ;send command & data to MAX7219
    
      RCALL delay_2s
;-----------------
      LDI   R17, 0x08       ;select digit 7
      LDI   R18, 0x0F       ;data = t
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x05       ;select digit 4
      LDI   R18, 0x4E       ;data = C
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x04       ;select digit 3
      LDI   R18, 0x00       ;data = space
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x03       ;select digit 2
      LDI   R18, 0x17       ;data = h
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      RET
;==============================================================
MAX7219_disp_text_light:
;-----------------
      
      RCALL MAX7219_clear
      RCALL delay1_s

      LDI   R17, 0x08       ;select digit 7
      LDI   R18, 0x0F       ;data = t
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x07       ;select digit 4
      LDI   R18, 0x4F       ;data = E
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x06       ;select digit 3
      LDI   R18, 0x05       ;data = r
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x05       ;select digit 2
      LDI   R18, 0x77       ;data = A
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x04       ;select digit 1
      LDI   R18, 0x15       ;data = n
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x03       ;select digit 1
      LDI   R18, 0x5E       ;data = G
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x02       ;select digit 1
      LDI   R18, 0x0       ;data = space
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x01       ;select digit 1
      LDI   R18, 0x0       ;data = space
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      RET
MAX7219_disp_text_dark:

      RCALL MAX7219_clear
      RCALL delay1_s

;-----------------
      LDI   R17, 0x08       ;select digit 7
      LDI   R18, 0x5E       ;data = G
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x07       ;select digit 4
      LDI   R18, 0x4F       ;data = E
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x06       ;select digit 3
      LDI   R18, 0x0E       ;data = L
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x05       ;select digit 2
      LDI   R18, 0x77       ;data = A
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x04       ;select digit 2
      LDI   R18, 0x67       ;data = P
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x03       ;select digit 1
      LDI   R18, 0x00       ;data = space
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x02       ;select digit 1
      LDI   R18, 0x00       ;data = space
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x01       ;select digit 1
      LDI   R18, 0x00       ;data = space
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      RET

;==============================================================
MAX7219_disp_text_moist:
;-----------------
      RCALL MAX7219_clear
      RCALL delay1_s
      ;--------------------------------------------------------
      LDI   R17, 0x08       ;select digit 8
      LDI   R18, 0b01110110       ;data = n
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x07       ;select digit 7
      LDI   R18, 0b01110000       ;data = n
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x06       ;select digit 6
      LDI   R18, 0x7E       ;data = o
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
       LDI   R17, 0x05       ;select digit 5
      LDI   R18, 0x06       ;data = i
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
       LDI   R17, 0x04       ;select digit 4
      LDI   R18, 0x5B       ;data = s
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x03       ;select digit 3
      LDI   R18, 0x0F       ;data = t
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x02       ;select digit 2
      LDI   R18, 0x00       ;data = SPACE
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x01       ;select digit 1
      LDI   R18, 0x00       ;data = SPACE
      RCALL send_bytes      ;send command & data to MAX7219
      ;-------------------------------------------------------- 
      LDI   R17, 0x00       ;select digit 0
      LDI   R18, 0x00       ;data = SPACE
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------     
      RET
;==============================================================
MAX7219_disp_text_dry:
;-----------------
      RCALL MAX7219_clear
      RCALL delay1_s

      LDI   R17, 0x09       ;set decoding mode command
      LDI   R18, 0b00000000 ;decoding byte
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x08       ;select digit 8
      LDI   R18, 0x3D       ;data = d
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x07       ;select digit 7
      LDI   R18, 0x05       ;data = r
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x06       ;select digit 6
      LDI   R18, 0x3B       ;data = y
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x05       ;select digit 5
      LDI   R18, 0x00       ;data = SPACE
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x04       ;select digit 4
      LDI   R18, 0x00       ;data = SPACE
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x03       ;select digit 3
      LDI   R18, 0x00       ;data = SPACE
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x02       ;select digit 2
      LDI   R18, 0x00       ;data = SPACE
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x01       ;select digit 1
      LDI   R18, 0x00       ;data = SPACE
      RCALL send_bytes      ;send command & data to MAX7219
      ;-------------------------------------------------------- 
      LDI   R17, 0x00       ;select digit 0
      LDI   R18, 0x00       ;data = SPACE
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------     
      RET


;==============================================================
send_bytes:
      CBI   PORTB, SS       ;enable slave device MAX7219
      OUT   SPDR, R17       ;transmit command
      ;--------------------------------------------------------
ll2:  IN    R19, SPSR
      SBRS  R19, SPIF       ;wait for byte transmission
      RJMP  ll2             ;to complete
      ;--------------------------------------------------------
      OUT   SPDR, R18       ;transmit data
      ;--------------------------------------------------------
ll3:  IN    R19, SPSR
      SBRS  R19, SPIF       ;wait for byte transmission
      RJMP  ll3             ;to complete
      ;--------------------------------------------------------
      SBI   PORTB, SS       ;disable slave device MAX7219
      RET

MAX7219_clear:
      LDI   R17, 0x09       ;set decoding mode command
      LDI   R18, 0b00000000 ;decoding byte
      RCALL send_bytes      ;send command & data to MAX7219

      LDI   R17, 0x08       ;select digit 7
      LDI   R18, 0x00       ;data = G
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x07       ;select digit 4
      LDI   R18, 0x00       ;data = E
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x06       ;select digit 3
      LDI   R18, 0x00       ;data = L
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x05       ;select digit 2
      LDI   R18, 0x00       ;data = A
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x04       ;select digit 2
      LDI   R18, 0x00       ;data = P
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x03       ;select digit 1
      LDI   R18, 0x00       ;data = space
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x02       ;select digit 1
      LDI   R18, 0x00       ;data = space
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x01       ;select digit 1
      LDI   R18, 0x00       ;data = space
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      RET

;==============================================================
binary2decimal:
;--------------
      CLR   R26             ;set counter1, initial value 0
      CLR   R27             ;set counter2, initial value 0
      ;--------------------------------------------------------
l70:  CPI   R28, 100        ;compare R28 with 100
Ret:  BRMI  l80             ;jump when R28 < 100
      INC   R26             ;increment counter1 by 1
      SUBI  R28, 100        ;R28 = R28 - 100
      RJMP  l70
      ;--------------------------------------------------------
l80:  CPI   R28, 10         ;compare R28 with 10
      BRMI  dsp             ;jump when R28 < 10
      INC   R27             ;increment counter2 by 1
      SUBI  R28, 10         ;R28 = R28 - 10
      RJMP  l80
      ;--------------------------------------------------------  
dsp:  MOV   R18, R27
      MOV   R17, R29        ;select digit
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      MOV   R18, R28
      MOV   R17, R30        ;select digit
      RCALL send_bytes      ;send command & data to MAX7219    
      ;--------------------------------------------------------
      RET

