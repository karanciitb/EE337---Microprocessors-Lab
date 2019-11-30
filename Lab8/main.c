/*
EE337 lab7: DAC IC tlv5616 interfacinng with pt-51
L.W.: (1) Complete spi() function from spi.h and dac() function from tlv5616.h so that this projecct will work properly 
			(2) Check whether it is working or not
			(3) Edit adc() function to make it genralized.
*/

#include <at89c5131.h>
//#include "lcd.h"																	//Driver for interfacing lcd 
#include "tlv1543.h"																//Driver for interfacing ADC ic tlv1543
#include "tlv5616.h"																//Driver for interfacinf DAC ic tlv56516
#include "filters.h"	
//Includes processing functions for filters
void msdelay(unsigned int time){
	int i,j;
	for(i=0;i<time;i++){
		for(j=0;j<382;j++);
}}
void main(void)
{
	unsigned int adc_data=0,dac_data=0,i=0;
	bit dir=0;
	spi_init();																				//AT89C5131A SPI initialization
	adc_init();																				//ADC IC (Here tlv1543) initialization
	dac_init();																				//DAC IC (Here tlv5616) initialization
	//lcd_init();																			//LCD initialization

	//Q1: Interface DAC and fill following while loop to generate Ramp waveform mantioned in a handout.

	 while(1)
		 	{   msdelay(7);
                dac(i);
		 		if (dir==0)
		 		{
                   i+=5;
                   if (i==4095){dir=1;}

		 	    }

		 	    if (dir==1)
		 	    {
                   i-=5;

                   if(i==0){dir=0;}
		 	    }
		 	}



	//Comment above while loop for Q2--------------------------------

	//Q2 : ADC and DAC
	 while(1){ 
	 adc_data=adc(1);
	 dac_data=adc_data<<2;
	//dac_data = moving_avg(dac_data); // uncomment this for Qn3
	 dac(dac_data);
	}

}

