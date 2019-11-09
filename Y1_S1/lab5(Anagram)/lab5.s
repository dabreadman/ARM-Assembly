;
; CS1021 2018/2019	Lab 5
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
	MOV	R1, #0x50		;
	STRB	R1, [R0]		;
	LDR	R0, =U0LCR		; R0 - > U0LCR (line control register)
	LDR	R1, =0x02		; 7 data bits + parity
	STRB	R1, [R0]		;


;
; My code
;


INIR0	LDR	R0, =STR0		; R0 -> "Input string"
		BL	PUTS			; put string
		LDR R4,=0x40000000	; Starting address
		MOV R12,#0			; NO.CHAR(inc. cr) = 0
	
INR0	BL	GET			; get character
		BL	PUT			; put character
		ADD R12,R12,#1	; ++NO.CHAR(inc. cr)
		STRB R0,[R4]	;
		ADD R4,R4,#1	; ++R4
		CMP R0,#0x0D	; if (R0 != cr)
		BNE INR0
	
		LDR R0, =STR3	; empty line
		BL PUTS
INIR1	LDR R5,=0x40000200	;S1 starting address
	
INR1	BL	GET			; get character
		BL	PUT			; put character
		STRB R0,[R5]	;
		ADD R5,R5,#1	; ++R5
		CMP R0,#0x0D	; if (R0 != cr)
		BNE INR1
		
COPYR0	LDR R6,=0x40000400	; S0 copy address
		LDR R4,=0x40000000	; R4 = starting address
		ADD R7,R4,R12		; R7 = ending address
COPYR0L		CMP R4,R7			; if (finish copying S0) 
			BEQ INICOMPARE			
			LDRB R8,[R4]		; 
			ADD R4,R4,#1		;
			STRB R8,[R6]		;S0 copied to R6
			ADD R6,R6,#1		;++R6
			B COPYR0L
			
INICOMPARE	LDR R6,=0x40000400	; S0 copy starting address
			LDR R5,=0x40000200	; S1 starting address 
			
			LDRB R0,[R5]		; R0 loads S1
COMPAREL	LDRB R8,[R6]		; R8 loads S0
			CMP R0,#0x0D		; if (R0) = cr
			BEQ YES				; finished 
			CMP R8,#0x0D		; if (R8) = cr 
			BEQ NO				; finished
			CMP R0,R8			; if (S0 contains S1's char)
			BEQ NEXTC
			ADD R6,R6,#1		; next S0 char
			LDRB R8,[R6]
			B COMPAREL
			
NEXTC		MOV R8,#0			; replace the identical char with 0
			STRB R8,[R6]		; stores the replaced char into memory		
			ADD R5,R5,#1		; proceed to the next char of S1
			LDRB R0,[R5]		; loads next S1 char into R0
			LDR R6,=0x40000400	; S0 copy starting address
			B COMPAREL
	
YES			LDR R0, =STR1		; loads "Y" into R0
			B PRINT
			
NO			LDR R0, =STR2		; loads "N" into R0

PRINT 		BL PUTS
			LDR R0, =STR3
			BL PUTS

ISR1EMPTY	BL GET				; get character
			BL PUT				; out character
			LDR R5,=0x40000200	; S1 starting address
			STRB R0,[R5]		; store char into R5
			ADD R5,R5,#1		; ++R5
			CMP R0,#0x0D		; if (next R0 == 0)
			BEQ INIR0			; overwrites S0
			B INR1				; overwrites S1
L B L			; forever
	
	

;
; subroutines
;	
; GET
;
; leaf function which returns ASCII character typed in UART #1 window in R0
;

;GETS PUSH {LR}


	;POP {PC}

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
	
	
STR0	DCB	"Input your string", 0x0a, 0
STR1 	DCB 0x0a,"Y",0
STR2 	DCB 0x0a,"N",0
STR3 	DCB "",0x0a,0,0
	
	END