;
; CS1021 2018/2019	Lab 4
; 

	AREA	RESET, CODE, READONLY
	ENTRY

;
; Q1   or EOR    ; 8 EOR 8 -> 4 EOR 4 -> ..
;				1110 -> 11 EOR 10 -> 01 ->1 *ODD
;				1111 -> 11 EOR 11 -> 00 ->0 *EVEN
;
;				1011 1011 1101 1101
;   	  EOR 	0000 0000 | 1101    11   0   1  * LSR #(8/n)
;				1011 1011   0010  | 00   1   0  * First half is unchanged
;				1011 1011   0010	00 | 1   0
;				1011 1011   0010	00	 0 | 1
;		  AND   #1


;		MOV R1, #42
;		MOV R0, #0
;		
;LOOP	CMP R1,#0
;		BLS OE
;		MOVS R1,R1, LSL #1  
;		ADC R0,R0,#0
;		B LOOP

;OE 		AND R0,R0,#1
;		CMP R0,#1

;
;	Q2
;

		MOV R0,#15 	; R0 = N
		MOV R1,#4	; R1 = D
		MOV R3,#0	; R3 = NO.BITS
		MOV R4,#1	; 1:(1)	; 10,11:(2)	; 100,101,110,111:(4)...(8)...(16)...
		MOV R5,#2	; NO.BITS is determined by 2^(NO.BITS-1)
		
BITS	CMP R0,R4		; N >= 2^(NO.BITS-1)
		BLO INIT
		ADD R3,R3,#1	; NO.BITS increases by 1
		MUL R4,R5,R4	; R4 = 2 ^ (NO.BITS - 1)
		B BITS

INIT	MOV R4,#0	; R4 = remainder *temp
		MOV R5,#0	; R5 = quotient *temp
		MOV R6,#1	; Used for logic operations
		RSB R7,R3,#32
		MOV R0,R3
		
FOR		CMP R3,#0
		BEQ END22
		SUB R3,R3,#1
		MOV R4,R4,LSL#1
		MOVS R3,R3,LSL#1
		ADC R4,R4,#0
		CMP R4,R1
		BLO	FOR
		SUB R4,R4,R1
		AND R5,R5,R6,LSL R3
		B FOR
		
		
END22
		
L	B	L		; infinite loop to end

        END
