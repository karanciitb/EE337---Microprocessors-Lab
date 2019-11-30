first equ p1.7
second equ p1.6
third equ p1.5
org 00h
	
ljmp main

DELAY_OF_50_MS:

	MOV R2,#185
	BACK1:
	MOV R1,#0FFH
	BACK :
	DJNZ R1, BACK
	DJNZ R2, BACK1
RET


DELAY_OF_250_MS:
	MOV R0, #7
	LOOP250 :
		ACALL DELAY_OF_50_MS
		DJNZ R0, LOOP250
RET

delay_of_d_4_sec:
	
	mov b, p1
	mov a, #0fh
	anl a, b
	mov r3, a
	loop_delay :
		acall DELAY_OF_250_MS
		djnz r3, loop_delay
ret

org 100h
main:
	mov p1,#0FH
	clr p1.4 
	setb first ;d
	setb second ;d_2
	setb third ;d_4
	loop:
		cpl first ;d
		cpl second ;d_2
		cpl third ;d_4
		
		
		ACALL delay_of_d_4_sec
		
		cpl third
		
		ACALL delay_of_d_4_sec
		
		cpl second
		cpl third
		
		ACALL delay_of_d_4_sec
		
		cpl third
		
		ACALL delay_of_d_4_sec
	
	sjmp loop
	
end