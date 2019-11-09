;
; CS1021 2018/2019	Lab 2
; 


	AREA	RESET, CODE, READONLY
	ENTRY

;
; add your code for Q1 here
;
		MOV	R2, #32   	; Counter: n = 32
		MOV R1, #0		; n(1) = 0  
		MOV R3, #1		; n(2) = 1

LOOP1	CMP R2, #1
		BEQ	END1
		ADD R0,R1,R3	;
		MOV R1,R3		; R1(n) = R3(n+1) 
		MOV R3,R0
		SUB R2,R2, #1	; 
		B LOOP1
		
		
END1	
			
;
; add your code for Q2 here
;

		MOV R0,#0
		MOV R1,#0
		MOV R2,#1
		
LOOP2	ADD R0,R1,R2
		MOV R1,R2
		MOV R2,R0
		MOV R3, #0x7FFFFFFF  ;MOV #0x7FFFFFFF for signed and #0xFFFFFFFF for unsigned 
		SUB R3,R3,R0
		CMP R3,R1
		BLS END2
		B LOOP2
		

		
END2	
	
	
STOP	B	STOP		; infinite loop to end

        END


