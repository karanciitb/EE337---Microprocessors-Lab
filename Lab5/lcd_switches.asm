; This subroutine writes characters on the LCD
LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable

ORG 0000H
ljmp start

org 200h
start:
      mov P2,#00h
      mov P1,#00h
	  
	  mov 99h,#99h
	  mov 88h,#88h
	  mov 77h,#77h
	  mov 66h,#66h
	  mov 55h,#55h
	  ;initial delay for lcd power up
	;here1:setb p1.0
      	  acall delay
	;clr p1.0
	  acall delay
	;sjmp here1
	  LCALL readNibble
	  MOV 4EH, A	;--- MSB
	  
	  LCALL readnibble
	  MOV 4FH, A ;-----LSB
	  
	  LCALL packnibbles
	  mov 50h, A ;---OVERALL ADDRESS
	  
	  
	  

	  acall lcd_init      ;initialise LCD
	
	  acall delay
	  acall delay
	  acall delay
	  mov a,#81h		 ;Put cursor on first row,5 column
	  acall lcd_command	 ;send command to LCD
	  acall delay
	  mov   dptr,#my_string1   ;Load DPTR with sring1 Addr
	  acall lcd_sendstring	   ;call text strings sending routine
	  acall delay
	  
	  mov a,50h
	  acall bin2ascii
	  mov a, 53h
	  acall lcd_senddata
	  mov a, 52h
	  acall lcd_senddata
	  
	  

	  mov a,#0C1h		  ;Put cursor on second row,3 column
	  acall lcd_command
	  acall delay
	  mov   dptr,#my_string2
	  acall lcd_sendstring
	  
	  mov r0, 50h
	  mov a, @r0
	  acall bin2ascii
	  mov a, 53h
	  acall lcd_senddata
	  mov a, 52h
	  acall lcd_senddata
	  
	  

 sjmp start				//stay here 

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

DELAY50:
MOV R2, #200
BACK11:
	MOV R1,#0FFH
	BACK22:
		DJNZ R1, BACK22
	DJNZ R2, BACK11
RET
;-------------ReadNibble
readNibble:
		
		MOV P1, #0FFH
		/*
		MOV R3, #100
		LOOP11:
			LCALL DELAY50 ; ---- 5s delay
		DJNZ R3, LOOP11
		
		MOV A, P1
		ANL A, #0FH
		MOV P1, A
		
		MOV R3, #20;---- 1s delay
		LOOP22:
			LCALL DELAY50
		DJNZ R3, LOOP22
		*/
		
		MOV R3, #100; ----- 5s delay
		LOOP33:
			LCALL DELAY50
		DJNZ R3, LOOP33
		MOV A, P1
		ANL A,#0FH
		RET
		
packNibbles:
		
	MOV A, 4EH ;--MSB
	SWAP A
	ORL A, 4FH ;--OR WITH LSB
	RET
;------------- ROM text strings---------------------------------------------------------------
org 400h
my_string1:
	DB   "Location:", 00H
my_string2:
	DB   "Contents:", 00H

	

LETTER:
	MOV A, @R1
	ADD A, #55
	MOV @R1,A
	RET
	
	NUMB:
	MOV A, @R1
	ADD A, #48
	MOV @R1,A
	RET

L1:
LCALL LETTER
SJMP BACK1

L2:
LCALL LETTER
SJMP BACK2

N1:
LCALL NUMB
SJMP BACK1

N2:
LCALL NUMB
SJMP BACK2

bin2ascii:

	setb psw.2
	clr psw.3

	MOV R1, #52H ; P2
	
	MOV R3, A
	ANL A, #0FH
	MOV @R1,A
	
	CLR C
	SUBB A, #10
	JNC L1
	JC N1
	
	BACK1:
	
	INC R1
	
	MOV A,R3
	SWAP A
	ANL A,#0FH
	MOV @R1,A
	
	CLR C
	SUBB A, #10
	JNC L2
	JC N2
	BACK2:
	
	clr psw.2
	
	RET	
end
