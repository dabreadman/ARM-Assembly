;
; CS1021 2018/2019	Lab 3
; 

	AREA	RESET, CODE, READONLY
	ENTRY

;
; add your code here
;
		LDR R0,=0x196 ;R0 = a
		LDR R1,=0x22B ;R1 = b

LOOP	CMP R0,R1 ;while(a != b)
		BEQ END1
		CMP R0,R1    ; a > b
		BLS ELSE
		SUB R0,R0,R1 ;a = a - b
		B RELOOP

ELSE	SUB R1,R1,R0 ;b = b - a
		
RELOOP	B LOOP		
		
		
END1		

;
;
;

		MOV R2,#0
		MOV R3,#0
		MOV R4,#0
		MOV R5,#1
		MOV R6,#64		; n = 64
		
LOOP2	CMP R6,#1
		BEQ END2
		ADDS R1,R3,R5
		ADC R0,R2,R4	; R0 = R2 + R4 + C
		MOV R3,R5
		MOV R5,R1
		MOV R2,R4
		MOV R4,R0	
		SUB R6,#1
		B LOOP2
		
		;R2R3   R4R5 R0R1
		; 0:1   0:1  0:2
		; 0:1   0:2  0:3
		; w+x > 2^32
		; 0:w   0:x  1:y
		; 0:x   1:y  ?:z
		
END2

;
;
;

		MOV R2,#0
		MOV R3,#0
		MOV R4,#0
		MOV R5,#1
		
LOOP3 	ADDS R1,R3,R5
		ADC R0,R2,R4
		MOV R3,R5
		MOV R5,R1
		MOV R2,R4
		MOV R4,R0	
		LDR R6,=0x7FFFFFFF
		SUB R6,R6,R0
		CMP R6,R2
		BLT END3
		B LOOP3
	
END3
		
STOP	B	STOP		; infinite loop to end

        END
