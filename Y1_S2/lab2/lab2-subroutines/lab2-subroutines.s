;
; CS1022 Introduction to Computing II 2018/2019
; Lab 2 - Subroutines
;

N	EQU	4
BUFLEN	EQU	32

PINSEL0	EQU	0xE002C000
U0RBR	EQU	0xE000C000
U0THR	EQU	0xE000C000
U0LCR	EQU	0xE000C00C
U0LSR	EQU	0xE000C014


	AREA	globals, DATA, READWRITE

; char buffer
BUFFER	SPACE	BUFLEN		; BUFLEN bytes

; result array
ARR_R	SPACE	N*4		; N words (4 bytes each)


	AREA	RESET, CODE, READONLY
	ENTRY


	BL	inithw

	
	; Q1 i
	;MOV R1,#2;	; A = 2
	;MOV R2,#3  ; B = 3	
	;BL max 	; calls subroutine max
	
	;Q1 ii
	;LDR R1,=0x40001000	; buffer starting address
	;MOV R2,#4			; LEN=4
	;BL gets			; calls subroutine gets
	
	;Q1 iii
	;LDR R0,=ARR_A
	;LDR R1,=ARR_B
	;LDR R2,=0x40000000	; result matrix address
	;BL matmul			; calls subroutine matmul
	

	

STOP	B	STOP


;Q1 (i)
; max subroutine
; Returns the largest value of two signed integers to R0
; Parameters
; R1 - integer
; R2 - another integer


max	PUSH{LR}
	CMP R1,R2
	BGT A
	MOV R0,R2
	B max1

A	MOV R0,R1

max1 POP{PC}

;Q1 (ii)
; gets subroutine
; read up to len-1 chars from from the console, storing the resulting NULL-terminated string in buffer
; and returning the number of characters read in R0
; Parameters
; R1 - address - char[]buffer
; R2 - length - amount of characters to read from console



gets PUSH{R4-R5,LR}
	 MOV R4,R1		; R4 = BUFFER 
	 MOV R5,R2		; R5 = LEN
	 LDR R0,=STR0	; loads STR0 into R0
	 BL puts		; output STR0 to the console
	 MOV R3,#1		; Counter
	 
gets0 	CMP R3, R5 		; while (<len-1)
		BEQ getsE
		BL get			; get a char from console
		BL put			; display the char on console
		CMP R0,#0x0D	; if (char!= CR)
		BEQ getsE		
		STR R0,[R4],#4	; stores the char in BUFFER, and post-increment by 4
		ADD R3,R3,#1	; Count++
		B gets0
	 
getsE	MOV R0,R3		; Count 
		POP{R4-R5,PC} 
	

;Q1 (iii)
; matmul
; multiply two matrices and storing the result in destination matrix (A * B = R)
; Parameters
; R0 - matrix A
; R1 - matrix B
; R2 - result matrix R

matmul	PUSH{R3-R11,LR}
		
	
	LDR R3, =N
 
	LDR R4, = 0 ;i
	LDR R5, = 0 ;j
	LDR R6, = 0 ;k
	LDR R7, = 0 ;r
	LDR R11, = 4; byte offset]
 
	
fLoop1Start	CMP R4, R3
	BGE fLoop1End
 
	
fLoop2Start 	CMP R5, R3
	BGE fLoop2End
 
	MOV R7, #0 ; r = 0
	
fLoop3Start	CMP R6, R3
	BGE fLoop3End
 
	MUL R8, R3, R6 ;kN
	ADD R8, R8, R4 ;kN + i
	MUL R8, R11, R8 ;Add byte offset to index
 
	LDR R8, [R0, R8]; Load value at A[i,k]
 
 
	MUL R9, R3, R5 ;jN
	ADD R9, R9, R6 ;jN + k
	MUL R9, R11, R9 ;Add byte offset to index
 
	LDR R9, [R0, R9]; Load value at B[k,j]
 
 
	MUL R8, R9, R8 ; A[ i , k ] * B[ k , j ]
	ADD R7, R7, R8 ; r = r + ( A[ i , k ] * B[ k , j ]
 
	ADD R6, R6, #1 ;k++
	B fLoop3Start
 

fLoop3End	MUL R10, R3, R5 ;[i,j] 1D convert....could use r9?
	 ADD R10, R10, R4 ;[i,j] 1D convert
	 MUL R10, R11, R10;Add byte offset to index........ R10 = memory address of [i,j]
	 
	 STR R7 , [R10,R2]  ;R[ i , j ] = r ;
	 
	 ADD R5, R5, #1 ;j++
	 MOV R6, #0
	 B fLoop2Start
	 
fLoop2End 	 ADD R4, R4, #1 ;i++
	 
	 MOV R5, #0
	 
	 B fLoop1Start

fLoop1End POP{R4-R12,PC}



;
; inithw subroutines
; performs hardware initialisation, including console
; parameters:
;	none
; return value:
;	none
;
inithw
	LDR	R0, =PINSEL0		; enable UART0 TxD and RxD signals
	MOV	R1, #0x50
	STRB	R1, [R0]
	LDR	R0, =U0LCR		; 7 data bits + parity
	LDR	R1, =0x02
	STRB	R1, [R0]
	BX	LR

;
; get subroutine
; returns the ASCII code of the next character read on the console
; parameters:
;	none
; return value:
;	R0 - ASCII code of the character read on teh console (byte)
;
get	LDR	R1, =U0LSR		; R1 -> U0LSR (Line Status Register)
get0	LDR	R0, [R1]		; wait until
	ANDS	R0, #0x01		; receiver data
	BEQ	get0			; ready
	LDR	R1, =U0RBR		; R1 -> U0RBR (Receiver Buffer Register)
	LDRB	R0, [R1]		; get received data
	BX	LR			; return

;
; put subroutine
; writes a character to the console
; parameters:
;	R0 - ASCII code of the character to write
; return value:
;	none
;
put	LDR	R1, =U0LSR		; R1 -> U0LSR (Line Status Register)
	LDRB	R1, [R1]		; wait until transmit
	ANDS	R1, R1, #0x20		; holding register
	BEQ	put			; empty
	LDR	R1, =U0THR		; R1 -> U0THR
	STRB	R0, [R1]		; output charcter
put0	LDR	R1, =U0LSR		; R1 -> U0LSR
	LDRB	R1, [R1]		; wait until
	ANDS	R1, R1, #0x40		; transmitter
	BEQ	put0			; empty (data flushed)
	BX	LR			; return

;
; puts subroutine
; writes the sequence of characters in a NULL-terminated string to the console
; parameters:
;	R0 - address of NULL-terminated ASCII string
; return value:
;	R0 - ASCII code of the character read on teh console (byte)
;
puts	STMFD	SP!, {R4, LR} 		; push R4 and LR
	MOV	R4, R0			; copy R0
puts0	LDRB	R0, [R4], #1		; get character + increment R4
	CMP	R0, #0			; 0?
	BEQ	puts1			; return
	BL	put			; put character
	B	puts0			; next character
puts1	LDMFD	SP!, {R4, PC} 		; pop R4 and PC


;
; test arrays
;

ARR_A	DCD	 1,  2,  3,  4
	DCD	 5,  6,  7,  8
	DCD	 9, 10, 11, 12
	DCD	13, 14, 15, 16

ARR_B	DCD	 1,  2,  3,  4
	DCD	 5,  6,  7,  8
	DCD	 9, 10, 11, 12
	DCD	13, 14, 15, 16
		
STR0	DCB	"Input your string", 0x0a, 0

	END
