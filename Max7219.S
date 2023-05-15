;------------------------
; Assembly Code
;------------------------
#define __SFR_OFFSET 0x00
#include "avr/io.h"
;------------------------
.global main

main:
  RCALL SPI_MAX7219_init
  RCALL MAX7219_disp_text

SPI_MAX7219_init:
;----------------
.equ  SCK, 5				;set port untuk SCK
.equ  MOSI, 3				;set port untuk MOSI
.equ  SS, 2					;set port untuk SS
;--------------------------------------------------------------
      LDI   R17, (1<<MOSI)|(1<<SCK)|(1<<SS)
      OUT   DDRB, R17       ;set MOSI, SCK, SS sebagai output
      ;--------------------------------------------------------
      LDI   R17, (1<<SPE)|(1<<MSTR)|(1<<SPR0)
      OUT   SPCR, R17       ;membuat SPI menjadi master, fsck = fosc/16
      ;--------------------------------------------------------
      LDI   R17, 0x0A       ;set intensitas segmen (0 ke 15)
      LDI   R18, 8          ;level intensitas = 8
      RCALL send_bytes      ;mengirim command dan data ke MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x09       ;set command mode decoding
      LDI   R18, 0b01100011 ;byte decoding
      RCALL send_bytes      ;mengirim command dan data ke MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x0B       ;set command set scan
      LDI   R18, 0x07       ;8 digits yang terknoneksi MAX7219
      RCALL send_bytes      ;mengirim command dan data ke MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x0C       ;set command ON/OFF
      LDI   R18, 0x01       ;menyalakan MAX7219
      RCALL send_bytes      ;mengirim command dan data ke MAX7219
      ;--------------------------------------------------------
      RET
;==============================================================
MAX7219_disp_text:
;-----------------
      LDI   R17, 0x08       ;memilih digit 7
      LDI   R18, 0x0F       ;data = t
      RCALL send_bytes      ;mengirim command dan data ke MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x05       ;memilih digit 4
      LDI   R18, 0x4E       ;data = C
      RCALL send_bytes      ;mengirim command dan data ke MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x04       ;memilih digit 3
      LDI   R18, 0x00       ;data = space
      RCALL send_bytes      ;mengirim command dan data ke MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x03       ;memilih digit 2
      LDI   R18, 0x17       ;data = h
      RCALL send_bytes      ;send command & data to MAX7219
      ;--------------------------------------------------------
      RET
;==============================================================
send_bytes:
      CBI   PORTB, SS       ;menyalakan slave device MAX7219
      OUT   SPDR, R17       ;mengirim command
      ;--------------------------------------------------------
ll2:  IN    R19, SPSR
      SBRS  R19, SPIF       ;menunggu untuk transmisi byte
      RJMP  ll2             ;to complete
      ;--------------------------------------------------------
      OUT   SPDR, R18       ;mengirim data
      ;--------------------------------------------------------
ll3:  IN    R19, SPSR
      SBRS  R19, SPIF       ;menunggu untuk transmisi byte
      RJMP  ll3             ;to complete
      ;--------------------------------------------------------
      SBI   PORTB, SS       ;mematikan slave device MAX7219
      RET
;==============================================================
binary2decimal:
;--------------
      CLR   R26             ;set counter1, nilai initial 0
      CLR   R27             ;set counter2, nilai initial 0 
      ;--------------------------------------------------------
l70:  CPI   R28, 100        ;bandingkan R28 dengan 100
Ret:  BRMI  l80             ;lompat ke R28 < 100
      INC   R26             ;increment counter1 by 1
      SUBI  R28, 100        ;R28 = R28 - 100
      RJMP  l70
      ;--------------------------------------------------------
l80:  CPI   R28, 10         ;bandingkan R28 with 10
      BRMI  dsp             ;lompat ketika R28 < 10
      INC   R27             ;increment counter2 by 1
      SUBI  R28, 10         ;R28 = R28 - 10
      RJMP  l80
      ;--------------------------------------------------------  
dsp:  MOV   R18, R27
      MOV   R17, R29        ;memilih digit
      RCALL send_bytes      ;mengirim command & data to MAX7219
      ;--------------------------------------------------------
      MOV   R18, R28
      MOV   R17, R30        ;memilih digit
      RCALL send_bytes      ;mengirim command & data to MAX7219    
      ;--------------------------------------------------------
      RET