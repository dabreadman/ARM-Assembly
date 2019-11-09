;
; CS1021 2018/2019	Lab 1
;

	AREA	RESET, CODE, READONLY
	ENTRY

;
; start of code
;
	LDR	R1, =5   	; x = 5
	LDR	R2, =6		; y = 6
	LDR R3, =2		; z = 2

;
; compute x*x + y + 4 (35 or 0x23)
;
	MUL	R0, R1, R1	; R0 = x*x
	ADD	R0, R0, R2	; R0 = x*x + y
	ADD	R0, R0, #4	; R0 = x*x + y + 4

;
;  (a) compute 3* x*x + 5*x
;

	MUL R0,R1,R1 	; R0 = x*x
	MOV R4,#3		  ; R4 = 3
	MUL R0,R4,R0	; R0 = 3* x*x
	MOV R4,#5	  	; R4 = 5
	MUL R4,R1,R4	; R4 = 5*x
	ADD R0,R0,R4 	; R0 = 3* x*x + 5* x

;
;  (b) compute 2* x*x + 6* x*y + 3* y*y
;

	MUL R0,R1,R1	; R0 = x*x
	MUL R4,R2,R2	; R4 = y*y
	MOV R5,#2	  	; R5 = 2
	MUL R0,R5,R0	; R0 = 2* x*x
	MOV R5,#3	  	; R5 = 3
	MUL R4,R5,R4	; R4 = 3* y*y
	ADD R0,R0,R4	; R0 = 2* x*x + 3* y*y
	MUL R4,R1,R2 	; R4 = x*y
	MUL R4,R2,R4	; R4 = 6* x*y
	ADD R0,R0,R4	; R0 = 2* x*x + 6* x*y + 3* y*y

;
;	(c) compute x*x*x - 4* x*x + 3* x + 8
;

	MOV R5,#4		  ; R5 = 4
	MUL R4,R1,R1 	; R4 = x*x
	MUL R5,R4,R5	; R5 = 4* x*x
	MUL R0,R1,R4	; R0 = x*x*x
	SUB R0,R0,R5	; R0 = x*x*x - 4* x*x
	MOV R4,#3	  	; R4 = 3
	MUL R4,R1,R4	; R4 = 3*x
	ADD R0,R0,R4	; R0 = x*x*x - 4* x*x + 3*x
	ADD R0,R0,#8	; R0 = x*x*x - 4* x*x + 3*x + 8

;
;	(d) compute 3* x*x*x*x - 5* x - 16* y*y*y*y* z*z*z*z
;


	MUL R4,R1,R1 	; R4 = x*x
	MUL R0,R4,R4	; R0 = x*x*x*x
	MOV R4,#3		; R4 = 3
	MUL R0,R4,R0	; RO = 3* x*x*x*x
	MOV R5,#5		; R5 = 5
	MUL R5,R1,R5	; R5 = 5* x
	SUB R0,R0,R5	; R0 = 3* x*x*x*x - 5* x
	MUL R4,R2,R2	; R4 = y*y
	MUL R5,R4,R4	; R5 = y*y*y*y
	MUL R4,R3,R3	; R4 = z*z
	MUL R6,R4,R4	; R6 = z*z*z*z
	MOV R7,#16		; R7 = 16
	MUL R4,R5,R6	; R4 = y*y*y*y* z*z*z*z
	MUL R4,R7,R4	; R4 = 16* y*y*y*y* z*z*z*z
	SUB R0,R0,R4 	; R0 = 3* x*x*x*x - 5* x - 16* y*y*y*y* z*z*z*z








L	B	L		; infinite loop to end programme

        END
