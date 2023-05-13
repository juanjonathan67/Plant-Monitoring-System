#define __SFR_OFFSET 0x00
#include "avr/io.h"

.global main

main:
  SBI DDRC, 0       ;set pin PC0 as i/p for ADC pin A0
  LDI R20, 0x40     ;voltage reference AVcc, right-justified, ADC pin A0
  STS ADMUX, R20    ;load to ADMUX
  LDI R20, 0x87     ;enable ADC, ADC prescaler CLK/128
  STS ADCSRA, R20   ;load to ADCSRA

init_serial:
  CLR R24                       ;clear R24
  STS UCSR0A, R24               ;clear UCSR0A register
  STS UBRR0H, R24               ;clear UBRR0H register
  LDI R24, 25                   ;store in UBRR0L 25
  STS UBRR0L, R24               ;to set baud rate 38400
  LDI R24, 1<<RXEN0 | 1<<TXEN0  ;load 1 to TXEN and RXEN
  STS UCSR0B, R24               ;enable RXB & TXB
  LDI R24, 0b00110110           ;load 00110110 to UCSR0C
  STS UCSR0C, R24               ;asynch, odd parity, 1 stop, 8 bits

print_ADC:
  LDI R23, 48      ;constants used to get ASCII values
  LDI R24, 7       ;for chars 0-->9 & A-->F

  LDI R20, 0xC7    ;set ADSC in ADCSRA to start conversion
  STS ADCSRA, R20  ;load to ADCSRA

wait_ADC:
  LDS R21, ADCSRA   ;check ADIF flag in ADCSRA
  SBRS R21, 4       ;skip jump when conversion is done (flag set)
  RJMP wait_ADC     ;loop until ADIF flag is set

  LDI R17, 0xD7     ;set ADIF flag again
  STS ADCSRA, R17   ;so that controller clears ADIF

  LDS R16, ADCL     ;get low-byte result from ADCL to R16
  LDS R25, ADCH     ;get high-byte result from ADCH to R25

  ADD R25, R23      ;add 48 to byte to get ASCII char 0 to 9

l1: 
  LDS R17, UCSR0A   ;load UCSR0A to R17
  SBRS R17, UDRE0   ;test data buffer if data can be sent
  RJMP l1           ;jump to l1

  STS UDR0, R25     ;print ADC MSD on serial monitor

  PUSH R16       ;store copy of ADCH in STACK register
  ANDI R16, 0xF0 ;mask & extract high-nibble
  SWAP R16       ;swap high-nibble with low-nibble
  ADD R16, R23   ;add 48 to byte to get ASCII char 0 to 9
  MOV R28, R16   ;store a copy of byte in R28
  SUBI R28, 58   ;subtract 58 from R28
  BRPL A_F_MSD   ;jump if result is positive (hexadecimal)

l2: 
  LDS R17, UCSR0A ;load UCSR0A to R17
  SBRS R17, UDRE0 ;test data buffer if data can be sent
  RJMP l2         ;jump to l2

  STS UDR0, R16   ;print ADC mid digit on serial monitor

  POP R16         ;restore ADCH value from STACK register
  ANDI R16, 0x0F  ;mask & extract low-nibble
  ADD R16, R23    ;add 48 to R16 to get 0 - 9
  MOV R28, R16    ;move to R28
  SUBI R28, 58    ;Substract by 58
  BRPL A_F_LSD    ;branch A_F_LSD (this digit is hexadecimal)

l3: 
  LDS R17, UCSR0A ;load UCSR01 to R17
  SBRS R17, UDRE0 ;test data buffer if data can be sent
  RJMP l3         ;jump to l3

  STS UDR0, R16   ;print ADC LSD on serial monitor

l4: 
  LDS R17, UCSR0A ;load UCSR0A to R17
  SBRS R17, UDRE0 ;test data buffer if data can be sent
  RJMP l4         ;jump to l4

  LDI R18, 0x0A   ;load ascii 10 (newline)
  STS UDR0, R18   ;print newline on serial monitor

l5: 
  LDS R17, UCSR0A ;load UCSR0A to R17
  SBRS R17, UDRE0 ;test data buffer if data can be sent
  RJMP l5         ;jump to l5

  LDI R18, 0x0D   ;load ascii 13 (carriage return = make cursor go to the very left)
  STS UDR0, R18   ;print carriage return on serial monitor

  RCALL delay_sec ;1 second delay
  RJMP print_ADC  ;jump to print_ADC

A_F_MSD:
  ADD R16, R24 ;add 7 to byte to get ASCII chars A to F
  RJMP l2      ;jump to l2

A_F_LSD:
  ADD R16, R24 ;add 7 to byte to get ASCII chars A to F
  RJMP l3      ;jump to l3

delay_sec:     ;1s delay
  LDI R20, 255 ;load 255 to R20
l6: 
  LDI R21, 255 ;load 255 to R21
l7: 
  LDI R22, 80  ;load 80 to R22
l8: 
  DEC R22      ;decrement R22
  BRNE l8      ;branch when finished
  DEC R21      ;decrement R21
  BRNE l7      ;branch when finished
  DEC R20      ;decrement R20
  BRNE l6      ;branch when finished
  RET          ;return