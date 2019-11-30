org 00h
ljmp main
matrix_transpose:
	USING 0
	MOV R2,50H
	MOV R4,50H
	MOV R0,#61H ; STORING STARTS FROM 61H
	MOV R1,#51H
	
	LOOP1:
		MOV A,R1
		MOV R5,A
		INC R5
		MOV A,R2
		MOV R3,A
		LOOP2:
			MOV A,@R1
			MOV @R0,A
			INC R0
			MOV A,R1
			ADD A,R2
			MOV R1,A
			DJNZ R3,LOOP2
		MOV A,R5
		MOV R1,A
		DJNZ R4,LOOP1
RET
ORG 100H
MAIN:
	AJMP matrix_transpose
	here: sjmp here
END