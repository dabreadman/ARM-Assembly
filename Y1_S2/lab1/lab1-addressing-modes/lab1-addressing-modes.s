;
; CS1022 Introduction to Computing II 2018/2019
; Lab 1 - Addressing Modes
;

N	EQU	10

	AREA	globals,DATA, READWRITE

; N word-size values

ARRAY	SPACE	N*4		; N words (4 bytes each)


	AREA	RESET, CODE, READONLY
	ENTRY

	; for convenience, let's initialise test array [0, 1, 2, ... , N-1]

	LDR	R0, = 0x40001000
	LDR	R1, =0
L1	CMP	R1, #N
	BHS	L2
	STR	R1, [R0, R1, LSL #2]
	ADD R1,R1,#1
	B	L1
L2

	; initialise registers for your program

;
; part i
;

	;MOV R2,#N			
	;MOV R4,#4         
	;MUL R2,R4,R2      		 ; total size in bytes
	;ADD R2,R2,R0		 ; end address
	;LDR	R0, =0x40001000	 ; array start address

	
		
;FORI	CMP R0,R2		; if (!ended)
		;BHS EFORI
		;LDR R3,[R0]		; loads from memory
		;MUL R5,R3,R3;	; squares
		;STR R5,[R0]		; stores into memory
		;ADD R0,R0,#4	; increments address
		
		;B FORI
;EFORI 


;
; part ii ##
;

	MOV R6,#0			;index
	MOV R2,#N			      
	MUL R2,R4,R2      		 ; total size in bytes
	ADD R2,R2,R0		 ; end address

		
FORI	CMP R6,#N		; if (!ended)
		BHS EFORI
		MOV R4,R6,LSL#2		
		BHS EFORI
		LDR R3,[R0,R4]		; loads from memory
		MUL R5,R3,R3;	; squares
		STR R5,[R0,R4]		; stores into memory
		ADD R6,R6,#1	; index increments
		
		
		B FORI
EFORI



;;
;; part iii
;;
	;MOV R4,#4 
	;MOV R2,#N		
	;MUL R2,R4,R2     	; total size in bytes
	;MOV R3,#0			; index	
	        
			
		
;FORI	CMP R3,#N			; if (!ended)
		;BHS EFORI
		;LDR R6,[R0,R3,LSL#2]		; loads from memory
		;MUL R5,R6,R6;			; squares
		;STR R5,[R0,R3,LSL# 2]		; stores into memory
		;ADD R3,R3,#1			; increments index
		
		;B FORI
;EFORI


;;
;; part iv
;;

	;MOV R2,#N			
	;MOV R4,#4         		 ; size of element
	;MUL R2,R4,R2      		 ; total size in bytes
	;ADD R2,R2,R0			 ; end address
	
		
;FORI	CMP R0,R2		; if (!ended)
		;BHS EFORI
		;LDR R3,[R0]		; loads from memory
		;MUL R5,R3,R3;	; squares
		;STR R5,[R0],R4	; stores into memory, and post increment
		
		;B FORI
;EFORI



STOP B STOP

	END

