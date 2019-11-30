/*
We set Date and Time in RTC IC and read the same from it and Display it on LCD
You can change Date and Time according to your own need and observe auto-updation of date and time by RTC.

DS1307 works in 100kHz mode by default.

We are using AT89C5131A in MASTER Transmit/Recieve mode ONLY !, to use the device in Slave mode refer the Datasheet.

Check the connections of SDA/SCL lines and Donot forget to give 5V to DS1307 apart from 3V battery back-up.

Students are encouraged to use this code fragment, modify, and craft out other possibilities beyond what they understand from this code.
*/

#include "at89c5131.h"
#include "math.h"
#include<stdio.h>
#include<string.h>

#define LCD_data  P2	    					// LCD Data port

//------ TWI register Definition ---------

// Refer page 102 of the 89c5131 Datasheet to fill-in the values of following variables

#define SSIE_enable 0x40
#define start_comm 0x20 

#define stop_comm 0xD1
#define bitrate 0x81

#define clear_TWI_start_stop_interrupt 0xC7
#define clear_TWI_stop_interrupt 0xE7

#define send_Ack 0xC5
#define send_Nack 0xC3
#define read_mode 0x01
#define write_mode 0x00

// ------ RTC Register Definition ------

 #define slave_add 0xD0 



#define clear_ext_interrupt 0xFB
#define seconds 0x00
#define minutes 0x00
#define hours 0x62
#define day 'T'
#define date 0x05
#define month 0x11
#define year 0x19
#define SQWE 0X10


sbit SDA = 		P4^1;
sbit SCL = 		P4^0;

sbit LCD_rs = P0^0;  								// LCD Register Select
sbit LCD_rw = P0^1;  								// LCD Read/Write
sbit LCD_en = P0^2;  								// LCD Enable

sbit LCD_busy = P2^7;								// LCD Busy Flag
sbit INT1 = P3^3;                   // setting interrupt as per connections

//---------- LCD Function Definition ----------
void LCD_Init();
void LCD_DataWrite(char dat);
void LCD_CmdWrite(char cmd);
void LCD_StringWrite(unsigned char *str);
void LCD_Ready(void);
void sdelay(int delay);

//----------- TWI Function Definition ----------

void TWI_init(void);
void Interrupt_init(void);
void start(void);
void Stop(void);
void Ack(void);
void Nack(void);
void display_data(void);
void write_one_time(void);
void read_one_time(void);

unsigned char conf[8] = {seconds,minutes,hours,day,date,month,year,SQWE}; // for reg 0x01 and 0x02
unsigned char mode[2] = {(slave_add | write_mode),(slave_add | read_mode)};
unsigned char Data[7],count=0,read,ext_int=0,high_nibble,low_nibble;

char MSB_read,LSB_read,flag;
int conf_index=0,mode_index=0,Data_index=0;
int clk,AM,PM;
char check;

/////////////////////////////////////////////////      Initialize Two wired Communication     //////////////////////////

void TWI_init(void)
{
		SDA =1; 									// set port lines
		SCL =1;
		SSCON &= 0x00;								// clear SSCON
		SSCON = SSCON | bitrate;  					// set bit frequency to 100kHz
		SSCON = SSCON | SSIE_enable;     			// synchronous serial enable bit
		SSCON = SSCON & clear_TWI_start_stop_interrupt;     // clear start,stop and serial interrupt fla
}

/////////////////////////////////////////////////     Interrupt handeler for Two wired Communication     //////////////////////////

void Interrupt_subroutine () interrupt 8 
{
	switch(SSCS)
	{

		case 0x08: /////// Start has been recieved ///////

			SSDAT = mode[mode_index++]; 			// SSDAT = write slave address + write mode
			SSCON &= clear_TWI_stop_interrupt; 		// clear stop flag and Interrupt flag
			break;

		case 0x10: /////// Repeat start has been recieved ///////

			SSDAT = mode[mode_index++]; 			// SSDAT = write slave address + read mode
			SSCON &= clear_TWI_stop_interrupt;      // clear interrupt and stop flag 
			break;

		case 0x20 : /////// SLA+W has been transmitted NOT ACK has been received  /////

			SSCON = stop_comm; // stop condition will be transmitted and interrupt flag cleared
			break;

		case 0x18: /////// Slave add + write mode Ack is recieved ///////

			SSDAT = 0x00;						    // SSDAT = write register address byte (set pointer address to 00h)
			SSCON &= clear_TWI_start_stop_interrupt; // clear start stop interrupt
			break;

		case 0x28: /////// Data written & Ack is recieved ///////

			if (!read) 								// enter when pointer address set to write
			{ 
				if(conf_index<8)
				{
					SSDAT=conf[conf_index++];		// SSDAT = write next data byte
					SSCON &= clear_TWI_start_stop_interrupt; 
				}	
				else
				{
					SSCON = stop_comm; 				// stop condition will be transmitted and interrupt flag cleared 
					flag=1; 						// flag set to indicate write has been done
				}
			}
			else
			{
				SSCON = stop_comm;                 // stop condition will be transmitted and interrupt flag cleared
				flag=1;							   // flag set to indicate write portion during read is complete
			}
			break;

		case 0X30 : /////// data byte has been transmitted and NOT ACK has been received ///////

			SSCON = stop_comm; 					   // stop condition will be transmitted and interrupt flag cleared
			break;


		case 0X40 : /////// SLA+R has been transmitted ACK has been transmitted ///////

			SSCON = send_Ack;                          // data byte will be received and ACK will be returned
			break;								   //clear start flag, stop flag and Interrupt flag

		case 0x48: /////// Slave add + Read mode Nack is recieved ///////

			SSCON = stop_comm; // stop condition will be transmitted and interrupt flag cleared
			break;

		case 0x50: /////// Data Read & Ack is recieved ///////

			if(Data_index < 5)
			{				
				Data[Data_index++]=SSDAT;
				SSCON = send_Ack; // data byte will be received and ACK will be returned
			}
			else
			{
				Data[Data_index++]=SSDAT;
				SSCON &= send_Nack; // data byte will be received and NOT ACK will be returned as next data is last data(years).
			}
			break;



		case 0X58 : // data byte has been received,NOT ACK has been returned

			Data[Data_index++]=SSDAT; // read years register
			Data_index = 0;					
			SSCON = stop_comm; // stop condition will be transmitted and interrupt flag cleared
			flag = 1;
			break;
			
		}		
}

/////////////////////////////////////////////////     Initialize External Interrupt and global Interrupt     //////////////////////////

void Interrupt_init(void)
{
		INT1=1;          //  Make P3.3 as Input to receive External Interrupt
		IEN0|=0x84;   // Enable all interrupts/Serialport Int/External Int 0
		IPL0|=0x04;   // Set the External interrupt priority as highest
		IPH0|=0x04;
		IEN1  |=0x02;    // Enable TWI interrupt - Refer IEN1 register
		IPL1 =0x00;    // Set the TWI interrupt priority as second highest
		IPH1 =0x02;
		TCON |=0x04;   // External interrupt falling edge triggered - Refer TCON register
}


/////////////////////////////////////////////////     External Interrupt Handler Subroutine     //////////////////////////

void Ext_interrupt_subroutine(void) interrupt 2 // Interrupt vector location for external interrupt
{
		ext_int = 1;							// Instead of doing everything in interrupt, we set a flag and do everything in main()
		TCON &= clear_ext_interrupt; 			// clear external interrupt on INT1 (P3.3)
}

/////////////////////////////////////////////////     Send Start on Two Wire Interface     //////////////////////////

void start(void)
{
		SSCON |=start_comm;
}

/////////////////////////////////////////////////     LCD Initialization     //////////////////////////

void LCD_Init()
{
		LCD_CmdWrite(0x38);   	// LCD 2lines, 5*7 matrix
		sdelay(100);
		LCD_CmdWrite(0x0E);			// Display ON cursor ON  Blinking off
		sdelay(100);
		LCD_CmdWrite(0x01);			// Clear the LCD
		sdelay(100);
		LCD_CmdWrite(0x80);			// Cursor to First line First Position
		sdelay(100);
}

/////////////////////////////////////////////////     LCD Busy Bit Check     //////////////////////////

void LCD_Ready()
{
		LCD_data = 0xFF;
		LCD_rs = 0;
		LCD_rw = 1;
		LCD_en = 0;
		sdelay(5);
		LCD_en = 1;
		while(LCD_busy == 1)
		{
			LCD_en = 0;
			LCD_en = 1;
		}
		LCD_en = 0;
}

/////////////////////////////////////////////////     LCD Command Write     //////////////////////////

void LCD_CmdWrite(char cmd)
{
		LCD_Ready();
		LCD_data=cmd;     			// Send the command to LCD
		LCD_rs=0;         	 		// Select the Command Register by pulling LCD_rs LOW
		LCD_rw=0;          			// Select the Write Operation  by pulling RW LOW
		LCD_en=1;          			// Send a High-to-Low Pusle at Enable Pin
		sdelay(1);
		LCD_en=0;
		sdelay(1);
}

/////////////////////////////////////////////////     LCD Character Write     //////////////////////////

void LCD_DataWrite( char dat)
{
		LCD_Ready();
		LCD_data=dat;	   				// Send the data to LCD
		LCD_rs=1;	   						// Select the Data Register by pulling LCD_rs HIGH
		LCD_rw=0;    	     			// Select the Write Operation by pulling RW LOW
		LCD_en=1;	   						// Send a High-to-Low Pusle at Enable Pin
		sdelay(1);
		LCD_en=0;
		sdelay(1);
}
/////////////////////  Function to split the string into individual characters and call the LCD_DataWrite function   ////////////////

void LCD_StringWrite(unsigned char *str)
{
    int i=0;
    while(str[i]!=0)
    {
        LCD_DataWrite(str[i]);
        i++;
    }
    return;
}

/////////////////////////////////////////////////     Delay loop     //////////////////////////

void sdelay(int delay)
{
	char d=0;
	while(delay>0)
	{
		for(d=0;d<5;d++);
		delay--;
	}
}

///////////////////////////////////////////////// BCD to ASCII ////////////////////////////////////////////////////

// Since we read from DS1307(BCD numbers) and display it to LCD (ASCII Values)
char conv_value;
void BCD_ASCII(unsigned char value)   //8 BIT
{
	conv_value = value + 0x30;
	// write the function to covert the BCD values to ASCII
}

///////////////////////////////////////////////// Display date and time //////////////////////////////////////////

//Display date and time on LCD Display
void Disp_time(void)
{
	
	LCD_CmdWrite(0x85);
	BCD_ASCII((Data[2] & 0xF0)>>4);
	LCD_DataWrite(conv_value);
	BCD_ASCII((Data[2] & 0x0F));
	LCD_DataWrite(conv_value);
	
	LCD_DataWrite('-');
	
	
	BCD_ASCII((Data[1] & 0xF0)>>4);
	LCD_DataWrite(conv_value);
	BCD_ASCII((Data[1] & 0x0F));
	LCD_DataWrite(conv_value);
	
	
	LCD_DataWrite('-');
	
		BCD_ASCII((Data[0] & 0xF0)>>4);
	LCD_DataWrite(conv_value);
	BCD_ASCII((Data[0] & 0x0F));
	LCD_DataWrite(conv_value);
	
	LCD_DataWrite('s');
	LCD_DataWrite('m');
	LCD_DataWrite('h');
	
	
	
	
	// Data register contains all data read from the slave device
	// 1ine 1-format: 	Time HH:MM:SS AM (or) Time HH:MM:SS PM [(or) Time HH:MM:SS Hr - in case of 24 hr format]
}


void Disp_date(void)
{
	
	LCD_CmdWrite(0xC5);
	BCD_ASCII((Data[3] & 0xF0)>>4);
	LCD_DataWrite(conv_value);
	BCD_ASCII((Data[3] & 0x0F));
	LCD_DataWrite(conv_value);
	
	LCD_DataWrite('/');
	
	BCD_ASCII((Data[4] & 0xF0)>>4);
	LCD_DataWrite(conv_value);
	BCD_ASCII((Data[4] & 0x0F));
	LCD_DataWrite(conv_value);	
	
	LCD_DataWrite('/');
	
	BCD_ASCII((Data[5] & 0xF0)>>4);
	LCD_DataWrite(conv_value);
	BCD_ASCII((Data[5] & 0x0F));
	LCD_DataWrite(conv_value);

  LCD_DataWrite('/');
	
	BCD_ASCII((Data[6] & 0xF0)>>4);
	LCD_DataWrite(conv_value);
	BCD_ASCII((Data[6] & 0x0F));
	LCD_DataWrite(conv_value);
	
	
	
	
	// Data register contains all data read from the slave device
	// 1ine 2-format: 	Date WW DD/MM/YY
}
/////////////////////////////////////////////////     Display Data    //////////////////////////

void display_data(void)
{
	Disp_time();
	Disp_date();
}


/////////////////////////////////////////////////     Write_one_time     //////////////////////////

void write_one_time()
{
		flag=0;
		mode_index = 0;
		conf_index = 0;
		read=0;
		start();
		while(!flag);
}
/////////////////////////////////////////////////     Read_one_time     //////////////////////////

void read_one_time()
{
		flag=0;
		mode_index = 0;
		Data_index = 0;
		read=1;
		start();
		while(!flag);
		flag = 0;
		start();
		while(!flag);
}

/////////////////////////////////////////////////     Main Programme     //////////////////////////
// Understand the main program

void main(void)
{

		P2 = 0x00;					// Make Port 2 output for LCD
		LCD_Init();					// Initialize LCD
		Interrupt_init();			// Initialize Interrupts for both I2C/TWI and External Interrupt INT1 connected to P3.3
		TWI_init();

		write_one_time();			// Write the Data to slave device
		LCD_CmdWrite(0x80);
		LCD_StringWrite("Time ");
		LCD_CmdWrite(0xC0);
		LCD_StringWrite("Date ");

		while(1)
		{
			if(ext_int)
			{
				ext_int=0;
				read_one_time();
				// Read the Data from slave device
				display_data();
				// Display the recieved data
			}
			conf[0]=conf[0] + 1;
		}
}
