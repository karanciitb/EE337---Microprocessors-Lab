; This subroutine writes characters on the LCD
LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable

ORG 0H
ljmp start

org 200h
start:
	  using 0
      mov P2,#00h
      mov P1,#00h
	  ;initial delay for lcd power up

      acall delay
	  acall delay

	  acall lcd_init      ;initialise LCD
	  acall delay
	  acall delay
	  acall delay
	  loopit:
	  mov a,#80h ; to put cursor on first row at the right place such that the padding is right
	  acall lcd_command
	  acall delay
	  mov   dptr,#my_string1
	  acall lcd_sendstring	   ;call text strings sending routine
	  acall delay
	  acall abpsw
	  
	  mov a,#0c0h
	  acall lcd_command
	  acall delay
	  mov   dptr,#my_string2
	  acall lcd_sendstring	   ;call text strings sending routine
	  acall delay
	  acall r012
	  
	  
	  acall DELAY_OF_5S
	  
	  
	  mov a,#80h ; to put cursor on first row at the right place such that the padding is right
	  acall lcd_command
	  acall delay
	  mov   dptr,#my_string3
	  acall lcd_sendstring	   ;call text strings sending routine
	  acall delay
	  acall r345
	  
	  mov a,#0c0h
	  acall lcd_command
	  acall delay
	  mov   dptr,#my_string4
	  acall lcd_sendstring	   ;call text strings sending routine
	  acall delay
	  acall r67sp
	  
	  acall DELAY_OF_5S
	  sjmp loopit
;-------------------- Binary to ASCII -----------
bin2ascii:
mov r2,a
swap a
anl a,#0fh
mov r0,a
mov b,#0ah
div ab
jz lb1
add a,#6h
lb1:add a,#30h
add a,r0
mov r0,a

mov a,r2
anl a,#0fh
mov r1,a
mov b,#0ah
div ab
jz lb2
add a,#6h
lb2:add a,#30h
add a,r1
mov r1,a
ret

;------------------------- ABPSW --------

abpsw:
mov a,#1ah
acall  bin2ascii
mov a,r0
acall lcd_senddata
acall delay
mov a,r1
acall lcd_senddata
acall delay

mov a,#" "
acall lcd_senddata
acall delay

mov b,#2bh
mov a,b
acall  bin2ascii
mov a,r0
acall lcd_senddata
acall delay
acall delay
mov a,r1
acall lcd_senddata
acall delay

mov a,#" "
acall lcd_senddata
acall delay

mov psw,#34h
mov a,psw
acall  bin2ascii
mov a,r0
acall lcd_senddata
acall delay
acall delay
mov a,r1
acall lcd_senddata
acall delay
ret
;------------------------R012---------------------
r012:
mov r0,#0abh
mov a,r0
acall  bin2ascii
mov a,r0
acall lcd_senddata
acall delay
acall delay
mov a,r1
acall lcd_senddata
acall delay
acall delay

mov a,#" "
acall lcd_senddata
acall delay

mov r1,#0bch
mov a,r1
acall  bin2ascii
mov a,r0
acall lcd_senddata
acall delay
acall delay
mov a,r1
acall lcd_senddata
acall delay
acall delay

mov a,#" "
acall lcd_senddata
acall delay

mov r2,#0deh
mov a,r2
acall  bin2ascii
mov a,r0
acall lcd_senddata
acall delay
acall delay
mov a,r1
acall lcd_senddata
acall delay
acall delay
ret
;--------------- R345 -----------------
r345:
mov r3,#12h
mov a,r3
acall  bin2ascii
mov a,r0
acall lcd_senddata
acall delay
acall delay
mov a,r1
acall lcd_senddata
acall delay

mov a,#" "
acall lcd_senddata
acall delay

mov r4,#23h
mov a,r4
acall  bin2ascii
mov a,r0
acall lcd_senddata
acall delay
acall delay
mov a,r1
acall lcd_senddata
acall delay
acall delay

mov a,#" "
acall lcd_senddata
acall delay
acall delay

mov r5,#34h
mov a,r5
acall  bin2ascii
mov a,r0
acall lcd_senddata
acall delay
acall delay
mov a,r1
acall lcd_senddata
acall delay
acall delay
ret
;---------------- R67SP ---------------
r67sp:
mov r6,#45h
mov a,r6
acall  bin2ascii
mov a,r0
acall lcd_senddata
acall delay
acall delay
mov a,r1
acall lcd_senddata
acall delay

mov a,#" "
acall lcd_senddata
acall delay
acall delay

mov r7,#56h
mov a,r7
acall  bin2ascii
mov a,r0
acall lcd_senddata
acall delay
acall delay
mov a,r1
acall lcd_senddata
acall delay
acall delay

mov a,#" "
acall lcd_senddata
acall delay

mov a,sp
acall  bin2ascii
mov a,r0
acall lcd_senddata
acall delay
acall delay
mov a,r1
acall lcd_senddata
acall delay
ret
;------------------------LCD Initialisation routine----------------------------------------------------
lcd_init:
         mov   LCD_data,#38H  ;Function set: 2 Line, 8-bit, 5x7 dots
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
	     acall delay

         mov   LCD_data,#0CH  ;Display on, Curson off
         clr   LCD_rs         ;Selected instruction register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         
		 acall delay
         mov   LCD_data,#01H  ;Clear LCD
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         
		 acall delay

         mov   LCD_data,#06H  ;Entry mode, auto increment with no shift
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en

		 acall delay
         
         ret                  ;Return from routine

;-----------------------command sending routine-------------------------------------
 lcd_command:
         mov   LCD_data,A     ;Move the command to LCD port
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
		 acall delay
    
         ret  
;-----------------------data sending routine-------------------------------------		     
 lcd_senddata:
         mov   LCD_data,A     ;Move the command to LCD port
         setb  LCD_rs         ;Selected data register
         clr   LCD_rw         ;We are writing
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         	 acall delay
		 acall delay
         ret                  ;Return from busy routine

;-----------------------text strings sending routine-------------------------------------
lcd_sendstring:
	push 0e0h
	lcd_sendstring_loop:
	 	 clr   a                 ;clear Accumulator for any previous data
	         movc  a,@a+dptr         ;load the first character in accumulator
	         jz    exit              ;go to exit if zero
	         acall lcd_senddata      ;send first char
	         inc   dptr              ;increment data pointer
	         sjmp  LCD_sendstring_loop    ;jump back to send the next character
exit:    pop 0e0h
         ret                     ;End of routine

;----------------------delay routine-----------------------------------------------------
delay:	 push 0
	 push 1
         mov r0,#1
loop2:	 mov r1,#255
	 loop1:	 djnz r1, loop1
	 djnz r0, loop2
	 pop 1
	 pop 0
	 ret
;-----------------
DELAY_OF_50_MS:
push ar1
push ar2
	MOV R2,#185
BACK1:
	MOV R1,#0FFH
	BACK :
	DJNZ R1, BACK
	DJNZ R2, BACK1
pop ar2
pop ar1
RET
DELAY_OF_5S:
push ar0
	MOV R0, #100
	LOOP250 :
		ACALL DELAY_OF_50_MS
		DJNZ R0, LOOP250
pop ar0
RET

my_string1:
	DB   "ABPSW = ", 00H
my_string2:
	DB   "R012 = ", 00H
my_string3:
	DB   "R345 = ", 00H
my_string4:
	DB   "R67SP =", 00H
end