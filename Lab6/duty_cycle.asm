pin equ p3.2
org 00H
ljmp main
org 0Bh
	ajmp timer
org 50h
timer:
	using 0
	inc a
	cjne a,#10,l2
	setb pin
	clr a
	l2:
	cjne a,ar0,l1
	clr pin
	l1:
	acall count_01ms
reti
	
count_01ms:
	clr TR0
	clr TF0
	mov TH0, #0FFh
	mov TL0, #38h
	setb TR0
ret

org 150h
main:
	setb pin
	mov a,p1
	anl a,#07h
	add a,#2
	mov r0,a
	mov a,#0
	mov TMOD, #01h
	mov TH0, #0FFh
	mov TL0, #0FFh
	mov IE, #82h
	setb TR0
	
	here: sjmp here
end