/*
EE337 lab7: ADC IC tlv1543 interfacinng with pt-51
L.W.: (1) Complete spi() function from spi.h so that this projecct will work properly 
			(2) Check whether it is working or not
			(3) Edit adc() function to make it genralized.
*/

#include <at89c5131.h>
#include "lcd.h"																		//Driver for interfacing lcd 
#include "tlv1543.h"																//Driver for interfacing ADC ic tlv1543


char adc_ip_data_ascii[6]={0,0,0,0,0,'\0'};					//string array for saving ascii of input sample
char display_msg1[]="ADC channel-00:";							//Display msg on 1st line of lcd
char display_msg2[]=" mV";													//Display msg on 2nd line of lcd
char display_msg01[]="ADC channel-01:";
char display_msg11[]="ADC channel-11:";
char display_msg12[]="ADC channel-12:";
char display_msg13[]="ADC channel-13:";

void main(void)
{
	unsigned int adc_data=0,dac_data=0,offset=600;
	

	spi_init();
	adc_init();
  	lcd_init();
  	// int offset = 600;
	
		// lcd_cmd(0x80);																	//Move cursor to first line
		// lcd_write_string(display_msg1);									//Display "ADC channel-00:" on first line of lcd
	while(1)
	{
	 	adc_data=adc(0);
		adc_data= (unsigned int)(3.225806452*adc_data - offset) ;// converting to milli volt (3.3*1000*i/p / 1023)
	
		int_to_string(adc_data,adc_ip_data_ascii);			//Convering integer to string of ascii
		lcd_cmd(0x80);																	//Move cursor to first line
		lcd_write_string(display_msg1);									//Display "ADC channel-00:" on first line of lcd
		lcd_cmd(0xC0);																	//Move cursor to 2nd line
		lcd_write_string(adc_ip_data_ascii);						//Print analog sampled input on lcd
		lcd_write_string(display_msg2);									//Display "XXXXX mV" on 2nd line of lcd
		msdelay(1997);//2s delay


		adc_data=adc(1);
		adc_data= (unsigned int)(3.225806452*adc_data - offset) ;// converting to milli volt (3.3*1000*i/p / 1023)
	
		int_to_string(adc_data,adc_ip_data_ascii);			//Convering integer to string of ascii
		lcd_cmd(0x80);																	//Move cursor to first line
		lcd_write_string(display_msg01);									//Display "ADC channel-00:" on first line of lcd
		lcd_cmd(0xC0);																	//Move cursor to 2nd line
		lcd_write_string(adc_ip_data_ascii);						//Print analog sampled input on lcd
		lcd_write_string(display_msg2);									//Display "XXXXX mV" on 2nd line of lcd
		msdelay(1997);//2s delay


		adc_data=adc(11);
		adc_data= (unsigned int)(3.225806452*adc_data - offset) ;// converting to milli volt (3.3*1000*i/p / 1023)
	
		int_to_string(adc_data,adc_ip_data_ascii);			//Convering integer to string of ascii
		lcd_cmd(0x80);																	//Move cursor to first line
		lcd_write_string(display_msg11);									//Display "ADC channel-00:" on first line of lcd
		lcd_cmd(0xC0);																	//Move cursor to 2nd line
		lcd_write_string(adc_ip_data_ascii);						//Print analog sampled input on lcd
		lcd_write_string(display_msg2);									//Display "XXXXX mV" on 2nd line of lcd
		msdelay(1997);//2s delay

		adc_data=adc(12);
		adc_data= (unsigned int)(3.225806452*adc_data - offset) ;// converting to milli volt (3.3*1000*i/p / 1023)
	
		int_to_string(adc_data,adc_ip_data_ascii);			//Convering integer to string of ascii
		lcd_cmd(0x80);																	//Move cursor to first line
		lcd_write_string(display_msg12);									//Display "ADC channel-00:" on first line of lcd
		lcd_cmd(0xC0);																	//Move cursor to 2nd line
		lcd_write_string(adc_ip_data_ascii);						//Print analog sampled input on lcd
		lcd_write_string(display_msg2);									//Display "XXXXX mV" on 2nd line of lcd
		msdelay(1997);//2s delay

		adc_data=adc(13);
		adc_data= (unsigned int)(3.225806452*adc_data - offset) ;// converting to milli volt (3.3*1000*i/p / 1023)
	
		int_to_string(adc_data,adc_ip_data_ascii);			//Convering integer to string of ascii
		lcd_cmd(0x80);																	//Move cursor to first line
		lcd_write_string(display_msg13);									//Display "ADC channel-00:" on first line of lcd
		lcd_cmd(0xC0);																	//Move cursor to 2nd line
		lcd_write_string(adc_ip_data_ascii);						//Print analog sampled input on lcd
		lcd_write_string(display_msg2);									//Display "XXXXX mV" on 2nd line of lcd
		msdelay(1997);//2s delay
	}
}