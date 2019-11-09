;
; CS1022 Introduction to Computing II 2018/2019
; Mid-Term Assignment - Connect 4 - SOLUTION
;
; get, put and puts subroutines provided by jones@scss.tcd.ie
;

PINSEL0	EQU	0xE002C000
U0RBR	EQU	0xE000C000
U0THR	EQU	0xE000C000
U0LCR	EQU	0xE000C00C
U0LSR	EQU	0xE000C014
ROWSIZE EQU 7
COLUMNSIZE EQU 6
BOARDSIZE EQU 42
XPIECE EQU 88
OPIECE EQU 79
EMPTYPIECE EQU 63
SIZE EQU 1
SPACEASCII EQU 32
HORLINE EQU 124


	AREA	globals, DATA, READWRITE			; only allocate the memory
BOARD	DCB	0,0,0,0,0,0,0
		DCB	1,1,1,1,1,1,1
		DCB	0,0,0,0,0,0,0
		DCB	1,1,1,1,1,1,1
		DCB	0,0,0,0,0,0,0
		DCB	1,1,1,1,1,1,1


	AREA	RESET, CODE, READONLY
	ENTRY

	; initialise SP to top of RAM
	LDR	R13, =0x40010000	; initialse SP

	; initialise the console
	BL	inithw

	; initialize the board
	LDR R0,=BOARD		
	MOV R1,#BOARDSIZE
	MOV R2,#EMPTYPIECE
	BL iniboard
	
	; WELCOME STRING
	LDR R0,=str_go
	BL puts
	
	
	
; GAME
	  MOV R9,#0   ;	COUNT
	  MOV R7,#0	  ; TOTAL PIECE
	
game1 LDR R0,=BOARD
	  BL printb ; calls printb subroutine
	  CMP R7,#BOARDSIZE	; IF BOARD IS FULL
	  BHS EVEN
	  CMP R9,#0	  ; if O's
	  BHI gameXA
	 
gameOA LDR R0,=str_O	; load O's string
       MOV R10,#OPIECE  ; PIECE = 0
	   B gameI

gameXA LDR R0,=str_X   ; loads X's string
       MOV R10,#XPIECE ; PIECE = X

gameI  BL puts		; output message for input to console
gameIL BL get		; get user input
	   BL put		; output user input to console
	   CMP R0,#0x0D	; if (char!= CR)
	   BEQ gameIE
	   SUB R8,R0,#48 ; ascii conversion
	   LDR R0,=str_newl
	   BL puts
	   B gameIL

gameII LDR R0,=str_error	; loads error message
	   B gameI

gameIE CMP R8,#0			; if the number is in range (0<i<=row)
	   BLS gameII
	   CMP R8,#ROWSIZE
	   BHI gameII
	   
gameInput  LDR R0,=BOARD	; LOADS BOARD ADDRESS
		   MOV R1,R8        ; MOVES COLUMN LOCATION
		   MOV R2,R10		; MOVES PIECE
		   BL input         ; calls input subroutine
		   CMP R0,#0		; if input is valid
		   BEQ gameII
		   
		   ADD R7,R7,#1		; TOTAL PIECE++
		   MOV R1,R0 		; MOVE LOCATION TO R1
		   LDR R0,=BOARD	; LOADS BOARD ADDRESS
		   MOV R2,R10		; LOADS PIECE
		   BL check		; calls check subroutine
		   CMP R0,#1		; if won
		   BEQ WON
		   CMP R9,#0		; CHANGE PLAYER
		   BEQ OchangeX
		   SUB R9,R9,#1
		   B game1
		   
OchangeX  ADD R9,R9,#1
		  B game1

WON 	CMP R10,#OPIECE
		BEQ OWON
		LDR R0,=str_XWON
		B finish
		
OWON	LDR R0,=str_OWON
		B finish
		
EVEN 	LDR R0,=str_EVEN
		B finish

finish BL puts
	   LDR R0,=BOARD	; prints the board
	   BL printb 

stop	B	stop


;
; your subroutines go here
;

; input
; adding pieces to the board by modifying the memory
; parameters:
;	board address in R0
;	column number in R1
;   piece in R2
; return values:
; 	0 in R0 if move is invalid
;   location in R0 if valid

input 
	PUSH{R4,LR}
	SUB R1,R1,#1		 ; index = number-1
	MOV R4,R0			 ; STORES STARTING ADDRESS
	ADD R0,R0,#BOARDSIZE ; ADDRESS ON LAST ROW
	ADD R0,R0,R1	     ; LOCATION OF COLUMN LAST ROW
	
input0	LDRB R1,[R0]
		CMP R1,#EMPTYPIECE	; IF LOCATION IS EMPTY 
		BNE	input1				
		STRB R2,[R0]		; STORES PIECE IN LOCATION
		B inputE

input1 SUB R0,R0,#ROWSIZE	; LOCATION SET TO UPPER ROW
	   CMP R0,R4			; IF LOCATION IS STILL INBOUND
	   BLO input2
	   B input0
	
input2 MOV R0,#0
	    
inputE POP{R4,PC}

; check subroutine
; check if the last move is winning move
; parameter:
; 	board address in R0
; 	piece location in R1
;	piece in R2
; return value:
;	1 in R0 if win
;   0 in R0 if not

check 
	PUSH{R4-R10,LR}
	MOV R4,R0				; STORES STARTING ADDRESS 
	ADD R5,R4,#BOARDSIZE	; STORES END ADDRESS+1
	MOV R6,R1				; PIECE LOCATION
	MOV R7,R2				; PIECE
	
ini		MOV R0,R4			; MOVES STARTING ADDRESS TO R0
; get horizontal boundaries
Hbound	CMP R0,R1			; IF R0 IS LESSER THAN LOCATION
		BHS HboundE
		ADD R0,#ROWSIZE		; INCREMENT R0 BY ROWSIZE
		B Hbound

HboundE SUB R0,R0,#1			; ALLIGN WITH PIECE ROW
		MOV R10,R0				; RIGHTMOST LOCATION OF THE ROW
		SUB R9,R0,#ROWSIZE		; OUT-OF-BOUNDS LEFTMOST LOCATION OF THE ROW

;checks horizontal
inicheckH MOV R1,R6			; MOVES PIECE LOCATION TO R1
		  MOV R0,#1			; COUNTER
		  
checkHL CMP R1,R9			; if in bound
		BLS checkHLE
		LDRB R2,[R1,#-SIZE]!	; loads element to the left
		CMP	R2,R7				; if equals
		BNE checkHLE
		ADD R0,R0,#1			; counter++
		CMP R0,#4				; if counter>winCondtion
		BHS WIN				
		B checkHL
		
checkHLE MOV R1,R6			    ; MOVES PIECE LOCATION TO R1
checkHR	 CMP R1,R10
		 BHI inicheckV
		 LDRB R2,[R1,#SIZE]!	; loads element to the right
		 CMP R2,R7				; if equals
		 BNE inicheckV
		 ADD R0,R0,#1			; counter++
		 CMP R0,#4				; if counter>winCondtion
		 BHS WIN				
		 B checkHR			

inicheckV 	MOV R1,R6	; MOVES PIECE LOCATION TO R1
			MOV R0,#1	; reset counter

checkVDOWN	LDRB R2,[R1,#ROWSIZE]!
			CMP R2,R7		; IF PIECE IS SAME
			BNE checkVDOWNE
			ADD R0,R0,#1	; COUNTER++
			CMP R0,#4		; IF NOT WON
			BHS WIN
			B checkVDOWN

checkVDOWNE	MOV R1,R6	; MOVES PIECE LOCATION TO R1
checkVUP	LDRB R2,[R1,#-ROWSIZE]!
			CMP R2,R7		; IF PIECE IS SAME
			BNE inicheckDLUP
			ADD R0,R0,#1	; COUNTER++
			CMP R0,#4		; IF NOT WON
			BHS WIN
			B checkVUP
			
inicheckDLUP	MOV R0,#1	; COUNTER
			MOV R1,R6	; MOVES PIECE LOCATION TO R1
checkDLUP	LDRB R2,[R1,#-ROWSIZE-1]! ; LOADS PIECE ELEMENT
			CMP R2,R7	; IF SAME WITH PIECE
			BNE checkDLUPE
			ADD R0,R0,#1 ; COUNTER++
			CMP R0,#4	 ; IF NOT WON
			BHS WIN
			B checkDLUP

checkDLUPE  MOV R1,R6	; MOVES PIECE LOCATION TO R1
checkDLDOWN	LDRB R2,[R1,#ROWSIZE+1]! ; LOADS PIECE ELEMENT
			CMP R2,R7	; IF SAME WITH PIECE
			BNE inicheckDRUP
			ADD R0,R0,#1 ; COUNTER++
			CMP R0,#4	 ; IF NOT WON
			BHS WIN
			B checkDLDOWN

inicheckDRUP	MOV R0,#1	; COUNTER
			MOV R1,R6	; MOVES PIECE LOCATION TO R1
checkDRUP	LDRB R2,[R1,#-ROWSIZE+1]! ; LOADS PIECE ELEMENT
			CMP R2,R7	; IF SAME WITH PIECE
			BNE checkDRUPE
			ADD R0,R0,#1 ; COUNTER++
			CMP R0,#4	 ; IF NOT WON
			BHS WIN
			B checkDRUP

checkDRUPE  MOV R1,R6	; MOVES PEICE LOCATION TO R1
checkDRDOWN	LDRB R2,[R1,#ROWSIZE-1]! ; LOADS PIECE ELEMENT
			CMP R2,R7	; IF SAME WITH PIECE
			BNE LOSE
			ADD R0,R0,#1 ; COUNTER++
			CMP R0,#4	 ; IF NOT WON
			BHS WIN
			B checkDRDOWN

WIN MOV R0,#1;	WINS
	B checkE

LOSE MOV R0,#0; NOT WON
	 B checkE
	
checkE POP{R4-R10,PC}

;
; printb subroutine
; prints boards to console
; paremeters:
; 	board address in R0
; return value:
; 	none
printb 
	PUSH {R4-R7,LR}
	MOV R4,R0	; COPIES STARTING ADDRESS
	MOV R5,#0	; COUNTER
	MOV R6,#0	; ROW-COUNTER
	MOV R7,#0	; ROW
	;LDR R0,=str_newl	; new line
	;BL puts
	MOV R0,#SPACEASCII
	BL put

; prints out column number
printt1	MOV R0,#HORLINE	; HORIZONAL SPACING
		BL put
		CMP R6,#ROWSIZE	; if finished the row
		BHS printt1E	
		ADD R0,R6,#48+1	; ASCII conversion
		BL put			
		ADD R6,R6,#1	; column++
		B printt1

printt1E LDR R0,=str_newl	; prints new line
		 BL puts
		 MOV R6,#0			; reset row counter
		 ADD R0,R6,#48+1    ; prints row number
		 ADD R7,R7,#1		; next row
		 BL put 

printb1	CMP R5,#BOARDSIZE	; if not finished
		BHS printbE
		CMP R6,#ROWSIZE		; if finished a row
		BHS printb3
		
printb2	MOV R0,#HORLINE	; HORIZONAL SPACING
		BL put
		LDRB R0,[R4],#SIZE	; put pieces on console, post increment to next
		BL put
		ADD R5,R5,#1		; counter++
		ADD R6,R6,#1		; row-counter++
		B printb1
		
printb3 MOV R0,#HORLINE	; HORIZONAL SPACING
		BL put
		LDR R0,=str_newl	; new line
		BL puts
		MOV R6,#0			; reset ROW-COUNTER
		ADD R7,R7,#1		; row++
		ADD R0,R7,#48		; ASCII conversion			
		BL put 				; prints row number
		B printb1
		
printbE	MOV R0,#HORLINE	; HORIZONAL SPACING
		BL put
		LDR R0,=str_newl
		BL puts
		POP{R4-R7,PC}

;
; iniboard subroutine
; initialize the board with a given value
; parameters:
; 	starting address in R0
; 	total size in R1
; 	element to be filled in R2
; return value:
; 	none
 

iniboard	CMP R1,#0
			BLS iniboardE
			STRB R2,[R0],#SIZE
			SUB R1,R1,#1
			B iniboard
		
iniboardE BX LR

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
; hint! put the strings used by your program here ...
;

str_go
	DCB	"Let's play Connect4!!",0xA, 0xD, 0

str_newl
	DCB	" ",0xD, 0xA, 0xD, 0
	
str_error
	DCB "Error, try again.",0xD, 0xA, 0xD, 0
	
str_X
	DCB "X's Turn. Enter column number(only last digit will be taken):",0xD, 0xA, 0xD, 0
	
str_O
	DCB "O's Turn. Enter column number(only last digit will be taken):",0xD, 0xA, 0xD, 0
	
str_OWON
	DCB "O won!:",0xD, 0xA, 0

str_XWON
	DCB "X won!",0xD, 0xA, 0
	
str_EVEN
	DCB "The match ended in even",0xD, 0xA, 0

	END
