
unsigned int moving_avg(unsigned int); 											//Takes current input sample and returns output of moving averege filter. 

enum{f_no_samples = 8};																			//Predifined number of samples to be saved or number of states for moving avg filter.


unsigned int moving_avg(unsigned int sample)
{
	static int cap=f_no_samples+1;														//Size of storage array
	static  int f_data[f_no_samples+1];												//Static saves old f_data values
  static signed int f_index=0;															//Pointer in storage array
	static signed int f_avg=0;																//Average value
	
		f_data[f_index++]= sample;															//Storing latest input ADC sample and incresing pointer location
		f_index %= cap;																					//Makes sure f_index iterates from 0 to f_no_samples+1
		f_avg += (sample - f_data[f_index]);										//Adds last f_no_samples and stores in f_avg
		
		return ((unsigned int) (f_avg/f_no_samples) & 0x0fff);	//Returns moving avarage value
}
