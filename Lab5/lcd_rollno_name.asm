; This subroutine writes characters on the LCD
LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable

ORG 0H
ljmp main

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
	  
	  mov r0,#081h
	  lcall shift
	  mov a,r3
	  add a,#80h ; to put cursor on first row at the right place such that the padding is right
	  acall lcd_command
	  acall delay
	  mov r0,#081h
	  acall lcd_sendstring	   ;call text strings sending routine
	  acall delay

	  mov r0,#90h
	  lcall shift
	  mov a,r3
	  add a,#0c0h ; to put cursor on second row at the right place such that the padding is right
	  acall lcd_command
	  acall delay
	  mov r0,#90h
	  acall lcd_sendstring	   ;call text strings sending routine

here: sjmp here				//stay here 

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
	lcd_sendstring_loop:
	         mov  a,@r0       ;load the first character in accumulator
	         jz    exit              ;go to exit if zero
	         acall lcd_senddata      ;send first char
	         inc   r0              ;increment data pointer
	         sjmp  LCD_sendstring_loop    ;jump back to send the next character
exit:    ret                     ;End of routine

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
;------------ for center padding --------
shift:
	push ar0
	mov r3,#0
	str_len:
		mov a,@r0
		jz ext
		inc r3
		inc r0
		sjmp str_len
ext:
	mov a,#16
	clr cy
	subb a,r3
	mov b,#2
	div ab
	mov r3,a
	pop ar0
ret
;--------main
main:
	mov r0,#81h
	MOV @R0,#"1"
		INC R0
	MOV @R0,#"7"
		INC R0
	MOV @R0,#"d"
		INC R0
	MOV @R0,#"0"
		INC R0
	MOV @R0,#"7"
		INC R0
	MOV @R0,#"0"
		INC R0
	MOV @R0,#"0"
		INC R0
	MOV @R0,#"2"
		INC R0
	MOV @R0,#"3"
		INC R0
	MOV @R0,#00H
	
	MOV R1,#90H
	MOV @R1,#"K"
		INC R1
	MOV @R1,#"a"
		INC R1
	MOV @R1,#"r"
		INC R1
	MOV @R1,#"a"
		INC R1
	MOV @R1,#"n"
		INC R1
	MOV @R1,#" "
		INC R1
	MOV @R1,#"C"
		INC R1
	MOV @R1,#"h"
		INC R1
	MOV @R1,#"a"
		INC R1
	MOV @R1,#"t"
		INC R1
	MOV @R1,#"e"
		INC R1
	MOV @R1,#00H

	lcall start
end