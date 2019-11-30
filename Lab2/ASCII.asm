ORG 00H
LJMP MAIN
ADD30_1:
	MOV R3,A
	MOV A,R2
	ADD A,#30H
	MOV @R1,A
	INC R1
	MOV A,R3
SJMP L1

ADD30_2:
	MOV R3,A
	MOV A,R2
	ADD A,#30H
	MOV @R1,A
	INC R1
	MOV A,R3
SJMP L3

ADD37_1:
MOV R3,A
	MOV A,R2
	ADD A,#37H
	MOV @R1,A
	INC R1
	MOV A,R3
SJMP L2

ADD37_2:
MOV R3,A
	MOV A,R2
	ADD A,#37H
	MOV @R1,A
	INC R1
	MOV A,R3
RET

bin2ascii_checksumbyte:
	using 0
	mov r0,50h
	mov r1,51h

	compute_checksum:
		MOV A,#0
		LOOP:
			ADD A,@R1
			INC R1
			DJNZ R0,LOOP
		CPL A
		ADD A,#1
		MOV @R1,A
		MOV R0,A
	MOV R1,52H ; WRITE POINTER
	ANL A,#0xF0
	SWAP A
	BIN2ASCII:
		MOV R2,A
		MOV B,#0AH
		DIV AB
		JZ ADD30_1
		L1:
		JNZ ADD37_1
		L2:
		MOV A,R0
		ANL A,#0x0F
		mov r2,a
		MOV B,#0AH
		DIV AB
		JZ ADD30_2
		L3:
		JNZ ADD37_2
RET

ORG 100H
MAIN:
	ACALL bin2ascii_checksumbyte
here: sjmp here
end