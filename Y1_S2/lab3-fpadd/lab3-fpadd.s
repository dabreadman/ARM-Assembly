;
; CS1022 Introduction to Computing II 2018/2019
; Lab 3 - Floating-Point Addition
;

	AREA	RESET, CODE, READONLY
	ENTRY

;
; Test Data
;
FP_A	EQU	0x41C40000
FP_B	EQU	0x41960000


	; initialize system stack pointer (SP)
	LDR	SP, =0x40010000
	
	; decode test
	LDR	R0, =FP_A		; test value A
	BL fpdecode
	
	; encode test
	LDR R0,=0x00C40000
	MOV R1,#4
	BL fpencode
	
	; add test
	LDR R0, =FP_A
	LDR	r1, =FP_B		; test value B
	BL	fpadd
	

stop	B	stop


;
; fpdecode
; decodes an IEEE 754 floating point value to the signed (2's complement)
; fraction and a signed 2's complement (unbiased) exponent
; parameters:
;	r0 - ieee 754 float
; return:
;	r0 - fraction (signed 2's complement word)
;	r1 - exponent (signed 2's complement word)
;
fpdecode
		PUSH {R4-R5,LR}
 		
dpdecode1 MOV R5,#0
		  MOVS R0,R0,LSL#1			;get the sign
		  ADC R5,R5,#0			
		  MOV R3,R0 				; creates a copy in R3
		  MOV R4,#0xFF
		  MOV R4,R4,LSL#24
		  AND R2,R0,R4			 	; extract the exponent part
		  MOV R2,R2,LSR#24			; get base value
		  SUB R1,R2,#127			; extract exponent
		  BIC R0,R3,R4				; clears the exponent part
		  MOV R0,R0,LSR#1			; remove the extra MSBit 0
		  ORR R0,R0,#0x00800000		; set the LSB to one to reflect hidden 1
		  CMP R5,#0					; if negative			
		  BEQ fpdecodeE
		  LDR R3,=0xFFFFFFFF
		  EOR R0,R0,R3				; invert the bits
		  ADD R0,R0,#1				; add one
		  
fpdecodeE		POP {R4-R5,PC}


;
; fpencode
; encodes an IEEE 754 value using a specified fraction and exponent
; parameters:
;	r0 - fraction (signed 2's complement word)
;	r1 - exponent (signed 2's complement word)
; result:
;	r0 - ieee 754 float
;
fpencode
	PUSH{R4,LR}
	AND R0, #0xFF7FFFFF	;remove hidden 1
	ADD R1, R1, #127	;add 127 to exp
	;MOV R3, R1			;store backup exp

;forStart2
	;MOVS R3,R3, LSL#1		;Move left until exp brought to left of reg.
	;ADC R2, R2, #0
	;CMP R2, #1
	;BEQ forEnd2
	;ADD R4, R4, #1		;inc counter
	;B forStart2
	
;forEnd2
	;SUB R4, R4, #2		;to reduce counter by one to regain lost 1 that triggered ADC, then reduce by one to fill to 31 bits
	MOV R1,R1,LSL#23	; shift exponent key to place
	;MOV R1,R1, LSL R4		;R1 - exp. ready to be loaded into encoded reg.
	ORR R0,R0,R1		; combine exponent with fraction
	POP{R4,PC}

;
; fpadd
; adds two IEEE 754 values
; parameters:
;	r0 - ieee 754 float A
;	r1 - ieee 754 float B
; return:
;	r0 - ieee 754 float A+B
;
fpadd
	PUSH{R4-R6,LR}
	MOV R9,R1		; creates a copy of float B
decode	
	BL fpdecode
	MOV R5,R0		; fraction a
	MOV R6,R1		; exponent a
	MOV R0,R9		; decode b
	BL fpdecode
	MOV R7,R0		; fraction b
	MOV R8,R1		; exponent b

expCMP CMP R6,R8		; if a<b
	   BLT	aSb
	   CMP R6,R8		; if a>b
	   BGT aBb

addFrac  ADD R0,R5,R7	; add both fractions
	   AND R2,R0,#0x01000000
	   CMP R2,#0		; if exceeded 24bits boundary
	   BEQ encode1	
	   ADD R6,#1		; adds the exponent
	   MOV R0,R0,LSR#1	; moves the larger bit into fraction
	   B encode1
		
aSb	CMP R6,R8		; if a<b
	BGE addFrac
	ADD R6,R6,#1	; adds exponent of a
	MOV R5,R5,LSR#1	; moves a fraction one place to left
	B aSb

aBb	CMP R6,R8		; if a>b
	BLE	addFrac
	ADD R8,R8,#1		; adds exponent of b
	MOV R7,R7,LSR#1  	; moves b fraction one place to left
	B aBb

encode1 MOV R1,R6
	   BL fpencode
	   POP {R4-R6,PC}


	END
