;------------------------
; Program to Read Value - YL39
; R25 - Low Byte Output YL39
; R26 - High Byte Output YL39
;------------------------
#define __SFR_OFFSET 0x00
#include "avr/io.h"
.global main
main:
  SBI DDRC, 0 ;men-set PINC 0 sebagai input untuk ADC
  LDI R20, 0xC0 ;internal 2.56V, right-justified data, ADC0
  STS ADMUX, R20
  LDI R20, 0x87 ;megaktifkan ADC, ADC prescaler CLK/128
  STS ADCSRA, R20
init_serial:
  CLR R24
  STS UCSR0A, R24 ;clear UCSR0A register
  STS UBRR0H, R24 ;clear UBRR0H register
  LDI R24, 103 ;& store in UBRR0L 103 value
  STS UBRR0L, R24 ;to set baud rate 9600
  LDI R24, 1<<RXEN0 | 1<<TXEN0 ;enable RXB & TXB
  STS UCSR0B, R24
  LDI R24, 1<<UCSZ00 | 1<<UCSZ01;asynch, no parity, 1 stop, 8 bits
  STS UCSR0C, R24
loop:
  RCALL delay_sec ;delay selama 1s
  RCALL print_ADC
  RCALL print_serial ;memanggil fungsi perkalian
  RJMP loop ;loop kembali
print_ADC:
LDI R20, 0xC7 ;set ADSC in ADCSRA to start conversion
STS ADCSRA, R20
;-----------------------------------------------------------------------
wait_ADC:
LDS R21, ADCSRA ;check ADIF flag in ADCSRA
SBRS R21, 4 ;skip jump when conversion is done (flag set)
RJMP wait_ADC ;loop until ADIF flag is set
;-----------------------------------------------------------------------
LDI R17, 0xD7 ;set ADIF flag again
STS ADCSRA, R17 ;so that controller clears ADIF
;-----------------------------------------------------------------------
LDS R25, ADCL ;mendapatkan low-byte yang berasal ADCL
LDS R26, ADCH ;mendapatkan high-byte yang berasal ADCH
;-----------------------------------------------------------------------
RET
print_serial:
  MOV R16, r26
  RCALL ASCII_MSD ;generate ASCII of MSD of r26
  RCALL LCD_buffer ;LCD buffer ready?
  STS UDR0, R16 ;menampilkan MSD dari result ke serial monitor

  RCALL ASCII_LSD ;generate ASCII of LSD of r26
  RCALL LCD_buffer ;LCD buffer ready?
  STS UDR0, R16 ;menampilkan LSD dari result ke serial monitor

  MOV R16, r25
  RCALL ASCII_MSD ;generate ASCII of MSD of r25
  RCALL LCD_buffer ;LCD buffer ready?
  STS UDR0, R16 ;menampilkan MSD dari result ke serial monitor

  RCALL ASCII_LSD ;generate ASCII of LSD of r25
  RCALL LCD_buffer ;LCD buffer ready?
  STS UDR0, R16 ;menampilkan LSD dari result ke serial monitor

  RCALL LCD_buffer ;LCD buffer ready?
  LDI R27, 0x0A
  STS UDR0, R27 ;print newline on serial monitor
  RET

LCD_buffer:
  LDS R27, UCSR0A
  SBRS R27, UDRE0 ;test data buffer if data can be sent
  RJMP LCD_buffer
  RET
ASCII_MSD:
  MOV R23, R16 ;save copy of result
  ANDI R16, 0xF0 ;extract & swap high-nibble
  SWAP R16
  SUBI R16, -48 ;R16 = R16 - (48) = R16 + 48
  MOV R28, R16 ;save a copy of high-byte result
  SUBI R28, 58 ;if +ve
  BRPL A_F_D1 ;branch & add 7 to get ASCII A to F
l1: RET
ASCII_LSD:
  MOV R16, R23 ;restore copy of result
  ANDI R16, 0x0F ;extract low-nibble
  SUBI R16, -48 ;R16 = R16 - (48) = R16 + 48
  MOV R28, R16 ;save a copy of high-byte result
  SUBI R28, 58 ;if +ve
  BRPL A_F_D0 ;branch & add 7 to get ASCII A to F
l2: RET
A_F_D1:
  SUBI R16, -7 ;R16 = R16 - (7) = R16 + 7
  RJMP l1
A_F_D0:
  SUBI R16, -7 ;R16 = R16 - (7) = R16 + 7
  RJMP l2
end:
delay_sec: ;1s delay
  LDI R20, 255 ; inisialisasi register R20 dengan nilai 255
  l4: LDI R21, 255 ; inisialisasi register R20 dengan nilai 255
  l5: LDI R22, 84 ; inisialisasi register R20 dengan nilai 84
  l6: DEC R22 ; kurangi nilai register R22 sebanyak 1
  BRNE l6 ; break ke l6 jika isi register tidak nol
  DEC R21 ; kurangi nilai register R21 sebanyak 1
  BRNE l5 ; break ke l5 jika isi register tidak nol
  DEC R20 ; kurangi nilai register R20 sebanyak 1
  BRNE l4 ; break ke l4 isi register jika tidak nol
  RET ; kembali ke main routine
