vec0 equ 50h
vec1 equ 51h
length equ 52h
write equ 53h
org 00h
ljmp main ; 2
inner_product:
mov r0, vec0 ; 2
mov r1, vec1 ; 2
mov r4, length ; 2
mov a,r4 ; 1
jz out ; 2
mov a,@r0 ; 1
mov b,@r1 ; 1
inc r0 ;1 
inc r1 ;1
mul ab ;4
mov r2,b ;1
mov r3,a ;1
dec r4 ;1
mov a,r4 ;1
jz out ;2
loop: ;14
	mov a,@r0 ;1
	mov b,@r1 ;1
	inc r0 ;1
	inc r1 ;1
	mul ab ;4
	add a,r3 ;1
	mov r3,a ;1
	mov a,r2 ;1
	addc a,b ;1
	mov r2,a ;1
	djnz r4,loop ;2
out: ;5
	mov r0,write
	mov a,r2
	add a,r3
	mov @r0,a
ret ;1
org 100h
main:
ajmp inner_product ; 2
here: sjmp here
end