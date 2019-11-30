pin equ P3.2
org 00h
ljmp main

org 0Bh
	ajmp timer
	
org 50h
timer:
	cpl pin
	clr TR0
	clr TF0
	mov TH0, #0FCh
	mov TL0, #18h
	setb TR0
reti
	
org 100h	
	
	
main:
	mov TMOD, #01h
	clr pin
	mov TH0, #0FCh
	mov TL0, #18h
	mov IE, #82h
	setb TR0
	
	here: sjmp here
end