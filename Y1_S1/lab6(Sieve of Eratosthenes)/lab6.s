;
; CS1021 2018/2019	Lab 6
;
; RAM @ 0x4000000 sz = 0x10000 (64K)
;

;
; hardware registers
;

PINSEL0	EQU	0xE002C000
	
U0RBR	EQU	0xE000C000
U0THR	EQU	0xE000C000
U0LCR	EQU	0xE000C00C
U0LSR	EQU	0xE000C014
	
	
	AREA	RESET, CODE, READONLY
	ENTRY	
	
;	
; hardware initialisation
;
	LDR	R13, =0x40010000	; initialse SP
	LDR	R0, =PINSEL0		; enable UART0 TxD and RxD signals
	MOV	R1, #0x50
	STRB	R1, [R0]
	LDR	R0, =U0LCR		; 7 data bits + parity
	LDR	R1, =0x02
	STRB	R1, [R0]

;
; 	set bits start
;

			LDR R1,=0xA			; R1 = N
			MOV R3,R1			; duplicates R1
			LDR R0,=0x40000000	; Array starting address
	
	
STRWORD			CMP R1,#32			; if (N >= 32)
			BLT STRHWORD
			LDR R2,=0xFFFFFFFF	; fill 32 1`s (word)
			STR R2,[R0],#4		; store into memory AND address increments by 4
			SUB R1,#32			; N = N - 32
			B STRWORD
		
STRHWORD		CMP R1,#16			; if (N >=16)
			BLT STRBYTE
			LDR R2,=0xFFFF		; fill 16 1`s (halfword) 
			STRH R2,[R0],#2		; store into memory AND address increments by 2
			SUB R1,#16			; N = N - 16
			B STRHWORD

STRBYTE    		 CMP R1,#8			; if (N >= 8)
			BLT STRBITINI
			LDR R2,=0xFF		; fill 8 1`s (byte)
			STRB R2,[R0],#1		; store into memory AND address increments by 1
			SUB R1,#8			; N = N - 8
			B STRBYTE
		
STRBITINI		MOV R2,#0			; initialize R2 =0
			STRB R2,[R0]		; initialize memory to access
			
STRBIT			CMP R1,#1			; if (N >=1)
			BLT CHECK
			LDRB R2,[R0]		; loads content from memory
			MOV R2,R2,LSL #1	; left shift content by 1 to left
			ADD R2,R2,#1		; set the LSBit to 1
			STRB R2,[R0]		; store into memory
			SUB R1,R1,#1		; N = N - 1
			B STRBIT

;
; 	set bits ends
;

CHECK			MOV R4,#0 			; R4 = count      |count++;
			LDR R9,=0x40000000
			MOV R1,R3			; R1 = N
			MOV R3,#2			; R3 = p   |for (int p = 2; p <= N; p++) {
FOR0			CMP R3,R1			; if (p <= N)
			BHI	EXITFOR0
		


			LDR R5,=0x40000000	; starting address
			MOV R5,#1			; mask
			MOV R6,R1,LSR #3	; R6 = address increment
			AND R2,R1,#7		; R2 = p % 8
			ADD R9,R9,R6
			LDRB R0,[R9]
			AND R0,R5,R0, LSL R2
			STRB R0,[R9]
			CMP R5,#0			; if (sieve[p]) 
			BEQ FOR0	
			ADD R4,R4,#1		; count++
			MOV R5,#2			; n = 2

FOR1			LDR R9,=0x40000000
			MOV R8,#1			; n
			MOV R5,#1			; mask
			MUL R6,R3,R5		; k = p * n
			CMP R6,R1			; if(k <= N)
			BHI FOR0
			MOV R7,R6,LSR #3	; R6 = address increment
			AND R2,R6,#7		; R2 = k % 8
			LDRB R0,[R9]		; loads
			BIC R0,R5,LSL R2	; clears
			STRB R0,[R9]		; stores
			ADD R8,R8,#1		; n++
			B FOR1
			


			
EXITFOR0























			;LDR R1,=0x49		; R1 = N
			;LDR R0,=0x40000000	; Array starting address
	
	
;STRWORD		CMP R1,#32			; if (N >= 32)
			;BLT STRHWORD
			;LDR R2,=0xFFFFFFFF	; fill 32 1`s (word)
			;STR R2,[R0],#4		; store into memory AND address increments by 4
			;SUB R1,#32			; N = N - 32
			;B STRWORD
		
;STRHWORD	CMP R1,#16			; if (N >=16)
			;BLT STRBYTE
			;LDR R2,=0xFFFF		; fill 16 1`s (halfword) 
			;STRH R2,[R0],#2		; store into memory AND address incremetns by 2
			;SUB R1,#16			; N = N - 16
			;B STRHWORD

;STRBYTE     CMP R1,#8			; if (N >= 8)
			;BLT STRBITINI
			;LDR R2,=0xFF		; fill 8 1`s (byte)
			;STRB R2,[R0],#1		; store into memory AND address increments by 1
			;SUB R1,#8			; N = N - 8
			;B STRBYTE
		
;STRBITINI	MOV R2,#0			; initialize R2 =0
			;STRB R2,[R0]		; initialize memory to access
;STRBIT		CMP R1,#1			; if (N >=1)
			;BLT CLEAR01
			;LDRB R2,[R0]		; loads content from memory
			;MOV R2,R2,LSL #1	; left shift content by 1 to left
			;ADD R2,R2,#1		; set the LSBit to 1
			;STRB R2,[R0]		; store into memory
			;SUB R1,R1,#1		; N = N - 1
			;B STRBIT

;;
;; 	set bits ends
;;


;CLEAR01			LDR R3,=0x40000000	; Array starting address
			;LDRB R2,[R3]		; loads content from 1st byte
			;MOV R2,R2, LSL #2	; clears 2 LSBit
			;STRB R2,[R3]		; store into memory
;;clears first 2 bits

;CHECKINI		MOV R4,#0			; R4 = cnt 
			;MOV R6,#0			; R6 = current number in decimal
			;MOV R7,#1			; Mask
			;LDR R10,=0x10000000	; Leftmost set bit
		
;CHECKL			LDRB R2,[R3]		; loads bit to R2 		
			;AND R8,R2,R7,LSL R6		; checks if bit is set
			;CMP R8,#0			; if (bit is set)
			;BHI CLEAR
			;CMP R7,R10			; if (mask reached leftmost position)
			;BEQ RESET0
			;MOV R7,R7,LSL #1
			;ADD R6,R6,#1		; decimal increments
			;B CHECKL
			
;RESET0			MOV R7,#1				
			;ADD R6,R6,#1		; decimal increments
			;ADD R3,R3,#1		; address increments
			;B CHECKL

;CLEAR 			ADD R4,R4,#1		; cnt++
			;MOV R11,#2			; n = 2
;CLEARL			LDR R2,=0x40000000	; R0 = starting address
			;MOV R7,#1			; mask
			;MUL R12,R6,R11		; R6 = k = p*n
			;CMP R12,R1			; if (k <= N)
			;BHI CHECKL
			;MOV R5,R6,LSR #3	; R5 = DECIMAL/8
			;ADD R2,R2,R5		; address increments by R5
			;LDRB R0,[R2]
			;AND R9,R6,#0x7		; R9 = k % 8
			;MOV R7,R7,LSL R9	
			;BIC R0,R0,R7		; sieve[k] = 0;
			;STRB R0,[R2],#1		; stores into memory AND post-increment
			;ADD R11,R11,#1		; n++
			;B CLEARL
	



STOP	B	STOP

;
; subroutines
;	
; GET
;
; leaf function which returns ASCII character typed in UART #1 window in R0
;
GET	LDR	R1, =U0LSR		; R1 -> U0LSR (Line Status Register)
GET0	LDR	R0, [R1]		; wait until
	ANDS	R0, #0x01		; receiver data
	BEQ	GET0			; ready
	LDR	R1, =U0RBR		; R1 -> U0RBR (Receiver Buffer Register)
	LDRB	R0, [R1]		; get received data
	BX	LR			; return

;	
; PUT
;
; leaf function which sends ASCII character in R0 to UART #1 window
;
PUT	LDR	R1, =U0LSR		; R1 -> U0LSR (Line Status Register)
	LDRB	R1, [R1]		; wait until transmit
	ANDS	R1, R1, #0x20		; holding register
	BEQ	PUT			; empty
	LDR	R1, =U0THR		; R1 -> U0THR
	STRB	R0, [R1]		; output charcter
PUT0	LDR	R1, =U0LSR		; R1 -> U0LSR
	LDRB	R1, [R1]		; wait until 
	ANDS	R1, R1, #0x40		; transmitter
	BEQ	PUT0			; empty (data flushed)
	BX	LR			; return

;	
; PUTS
;
; sends NUL terminated ASCII string (address in R0) to UART #1 window
;
PUTS	PUSH	{R4, LR} 		; push R4 and LR
	MOV	R4, R0			; copy R0
PUTS0	LDRB	R0, [R4], #1		; get character + increment R4
	CMP	R0, #0			; 0?
	BEQ	PUTS1			; return
	BL	PUT			; put character
	B	PUTS0			; next character
PUTS1	POP	{R4, PC} 		; pop R4 and PC





	END