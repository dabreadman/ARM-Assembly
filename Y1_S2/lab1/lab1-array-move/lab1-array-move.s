;
; CS1022 Introduction to Computing II 2018/2019
; Lab 1 - Array Move
;

N	EQU	9		; number of elements

	AREA	globals, DATA, READWRITE

; N word-size values

0x40001000	SPACE	N*4		; N words


	AREA	RESET, CODE, READONLY
	ENTRY

	; for convenience, let's initialise test array [0, 1, 2, ... , N-1]

	LDR	R0, =0x40001000
	LDR	R1, =0
L1	CMP	R1, #N
	BHS	L2
	STR	R1, [R0, R1, LSL #2]
	ADD	R1, R1, #1
	B	L1
L2

	; initialise registers for your program

	LDR	R0, =0x40001000
	LDR	R1, =6			; target index
	LDR	R2, =3			; destination index
	LDR	R3, =N			

	; your program goes here

	MOV R4,R0			; R4=0x40001000
	ADD R4,R4,R1,LSL #2 	; target address
	MOV R5,R0			; R5=0x40001000
	ADD R5,R5,R2,LSL #2	; destination address
	LDR R9,[R4]			; loads destination element 
	CMP R1,R2			;
	BHI FORHIGH
	B FORLOW
		
FORHIGH	CMP R4,R5		; if passed destination 
		BEQ HIGH
		LDR R6,[R4,#-4]	; loads item from i-1
		STR R6,[R4],#-4	; stores item in i, then decrement by 4
		B FORHIGH
HIGH 	STR R9,[R4]	; stores target element into destination
		B CHECK

FORLOW	CMP R4,R5
		BEQ LOW
		LDR R6,[R4,#4]	; loads item from i+1
		STR R6,[R4],#4	; stores item in i, then increment by 4
		B FORLOW
LOW		STR R9,[R4]		; stores target element into destination
		B CHECK


;checks each element
CHECK 	MOV R6,#0;		; COUNT = 0
CHECKL	CMP R6,R3		; while (inArray)
		BHI EXIT
		LDR R5,[R0],#4	; loads target element into registry
		ADD R6,#1
		B CHECKL
EXIT


STOP	B	STOP

	END


