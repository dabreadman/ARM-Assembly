;
; CS1022 Introduction to Computing II 2018/2019
; Lab 1 - Matrix Multiplication
;
N EQU 4
 AREA globals, DATA, READWRITE
; result matrix R
ARR_R SPACE N*N*4  ; 4 * 4 * word-size values

 AREA RESET, CODE, READONLY
 ENTRY
 LDR R0, =ARR_A
 LDR R1, =ARR_B
 LDR R2, =ARR_R
 LDR R3, =N
 ; your program goes here
 LDR R4, = 0 ;i
 LDR R5, = 0 ;j
 LDR R6, = 0 ;k
 LDR R7, = 0 ;r
 LDR R11, = 4; byte offset]
 
fLoop1Start
 CMP R4, R3
 BGE fLoop1End
 
fLoop2Start 
 CMP R5, R3
 BGE fLoop2End
 
 MOV R7, #0 ; r = 0
fLoop3Start
 CMP R6, R3
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
 
fLoop3End
 MUL R10, R3, R5 ;[i,j] 1D convert....could use r9?
 ADD R10, R10, R4 ;[i,j] 1D convert
 MUL R10, R11, R10;Add byte offset to index........ R10 = memory address of [i,j]
 
 STR R7 , [R10,R2]  ;R[ i , j ] = r ;
 
 ADD R5, R5, #1 ;j++
 MOV R6, #0
 B fLoop2Start
 
fLoop2End 
 ADD R4, R4, #1 ;i++
 
 MOV R5, #0
 
 B fLoop1Start
fLoop1End 
 
STOP B STOP
; two constant value matrices, A and B
ARR_A DCD  1,  2,  3,  4
 DCD  5,  6,  7,  8
 DCD  9, 10, 11, 12
 DCD 13, 14, 15, 16
ARR_B DCD  1,  2,  3,  4
 DCD  5,  6,  7,  8
 DCD  9, 10, 11, 12
 DCD 13, 14, 15, 16
  
  
 END


