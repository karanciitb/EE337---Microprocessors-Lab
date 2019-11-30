#include "at89c5131.h"
#include "serial.c"
void main(void)
{
   unsigned char ch='A';
   uart_init();					//Call function to initialize UART
	TMOD = 0x20;
	TH1 = 0xCC;
	SCON = 0x40;
	ES = 1;
	EA = 1;
	TR1 = 1;
   while(true)
	 {
     		//Call function to transmit 'A'
		 transmit_char(ch);
		//Call 100 ms delay function
		 msdelay(100);
   }		 
}
