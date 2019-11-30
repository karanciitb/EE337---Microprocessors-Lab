#include <at89c5131.h>
#include "lcd.h"
#include "serial.c"

sbit LED7=P1^7;
sbit LED6=P1^6;
sbit LED5=P1^5;
sbit LED4=P1^4;
sbit s0 = P1^0;
sbit s1 = P1^1;
sbit s2 = P1^2;
sbit s3 = P1^3;
unsigned char intr_count = 0,rx_buf = 0;
char lcd_display[] = "LCD is tested";
unsigned int ctr ;

void gpio_test(void)
{
	TR0 = 0; // to stop timer_test

	LED4 = s3;
	LED5 = s2;
	LED6 = s1;
	LED7 = s0;
}	

void led_test(void)
{
	TR0 = 0; // to stop timer_test
LED7=~LED7;
LED6=~LED6;
LED5=~LED5;
LED4=~LED4;
}

void lcd_test(void)
{
	TR0 = 0; // to stop timer_test
lcd_cmd(0x80);
lcd_write_string(lcd_display);
}	

void timer_test(void) // uses Timer 0 as Timer 1 is used for UART
{
TMOD |= 0x01;
TH0 = 0xF0;	// Timer set for a time
TL0 = 0x60; // duration of 2 ms
ctr = 0;
ET0 = 1;
TR0 = 1;

}
void timer_interrupt(void) interrupt 1
{
	TF0 = 0;
	ctr++;
	if(ctr == 250){ // 2*250 = 500 ms
		ctr = 0;
		LED7 = ~LED7;
	}
	TH0 = 0xF0;
	TL0 = 0x60;
	TR0 = 1;
}
void main(void)
{
	unsigned char ch=0;
	P1 = 0x0F;
	lcd_init();
	uart_init();
	transmit_string("************************\r\n");
	transmit_string("******8051 Tests********\r\n");
	transmit_string("************************\r\n");
	transmit_string("Press 1 for GPIO test\r\n");
	transmit_string("Press 2 for LED test\r\n");
	transmit_string("Press 3 for LCD test\r\n");
	
	while(1)
	{
			ch = receive_char();
			switch(ch)
			{
				case '1':gpio_test();
								 transmit_string("GPIO tested\r\n");
								 break;
				case '2':led_test();
								 transmit_string("LED tested\r\n");
								 break;
				case '3':lcd_test();
								 transmit_string("LCD tested\r\n");
								 break;
				case '4':timer_test();
								 transmit_string("Timer tested\r\n");
								 break;
								
				default:transmit_string("Incorrect test.Pass correct number\r\n");
								 break;
				
			}		
	}
}
