pin equ P3.2
org 00h
ljmp main
	
org 100h

main:
	mov TMOD, #01h
	clr pin
	loop:
		mov TH0, #0FCh
		mov TL0, #18h
		cpl pin
		setb TR0
		here: jnb TF0, here
		clr TR0
		clr TF0
		sjmp loop
end