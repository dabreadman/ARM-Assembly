;
; CS1022 Introduction to Computing II 2018/2019
; Lab 2 - Recursion
;

N	EQU	10

	AREA	globals, DATA, READWRITE

; N word-size values

SORTED	SPACE	N*4		; N words (4 bytes each)


	AREA	RESET, CODE, READONLY
	ENTRY

	;
	; copy the test data into RAM
	;

	LDR	R4, =SORTED
	LDR	R5, =UNSORT
	LDR	R6, =0
whInit	CMP	R6, #N
	BHS	eWhInit
	LDR	R7, [R5, R6, LSL #2]
	STR	R7, [R4, R6, LSL #2]
	ADD	R6, R6, #1
	B	whInit
eWhInit

	
	;LDR R0,=UNSORT ; R0=ARR
	;MOV R1,#2			; i=2
	;MOV R2,#5			; j=5
	;BL swap			; calls subroutine swap


	
	
	LDR R0,=SORTED		; R0=ARR
	MOV R1,#N			; N elements
	BL sort				; calls subroutine sort

STOP	B	STOP


;Q2a

;swap(array, i, j)
;
;
; swap
; swaps two element of a 1*1 dimension array
; Parameters
; R0 - array
; R1 - first element index
; R2 - second element index

swap PUSH{R4-R5,LR}
	 MOV R4,R1	; first element index
	 MOV R5,R2	; second element index
	 
	 LDR R1,[R0,R4, LSL#2]	; element address 1
	 LDR R2,[R0,R5, LSL#2]	; element address 2
	 
	 STR R1,[R0,R5, LSL#2]
	 STR R2,[R0,R4, LSL#2]
	 POP {R4-R5,PC}
	
;sort
; bubble sort an array of numbers
; Parameters
; R0 - array
; R1 - number of elements

sort PUSH{R4-R9,LR}
	 MOV R6,R1		;
	 MOV R10,R0
	
fLoop1Start	MOV R4, #1			; i = 1
			
			MOV R7,#0			; SWAPPED = false

	
fLoop		CMP R4, R6		;	while (i<N)
			BGE fLoop1End
			SUB R5, R4,#1		; i - 1
			
ifStat		LDR R8,[R0,R4,LSL#2]	; ARR[I]
			LDR R9,[R0,R5,LSL#2]	; ARR[i-1]
			CMP R9 , R8			;if(ARR[i-1]>ARR[i])
			BLE ifEnd
			MOV R1,R5	; i-1
			MOV R2,R4	; i
			BL swap		; calls subroutine swap
			ADD R7,R7,#1	; SWAPPED = true

ifEnd 	ADD R4,R4,#1		;i++	 
		
		B fLoop

fLoop1End CMP R7,#1
		  BLO   doWhileEnd
		  B fLoop1Start

doWhileEnd POP {R4-R9,PC}


UNSORT	DCD	9,3,0,1,6,2,4,7,8,5

	END
