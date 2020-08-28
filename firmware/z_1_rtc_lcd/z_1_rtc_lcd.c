#include "z_1_rtc_lcd.h"
// LCD: https://www.newhavendisplay.com/specs/NHD-0420H1Z-FL-GBW-33V3.pdf
void lcd_send_str(char* str) {
	for(int next_char = 0; *(str+next_char); next_char++){
		lcd_send_char(*(str+next_char), 0x0);
	}
}

void lcd_send_screen(char* ln0, char* ln1, char* ln2, char* ln3, char update) {
	if(update & (1<<4)) {
			lcd_send_char(0x01, 0x1);    //clear display
	}

	if(update & 1<<3) {
		lcd_send_char(0x80, 0x1);// set DDR ADDR to zeroth line
		lcd_send_str(ln0);
	}

	if(update & (1<<2)) {
		lcd_send_char(0xC0, 0x1); // set DDRAM ADDR to first line
		lcd_send_str(ln1);
	}

	if(update & (1<<1)) {
		lcd_send_char(0x94, 0x1); // set DDRAM ADDR to second line
		lcd_send_str(ln2);
	}
	
	if(update & 1<<0) {
		lcd_send_char(0xD4, 0x1); //set DDRRAM ADDR to third line
		lcd_send_str(ln3);
	}
}

void lcd_send_char(char i, char command) {	
	// apply i to LCD databus (spread over port E and D)
	PORTE = (i>>6) | (PORTE & 0xFC);
	PORTD = (i<<2) | (PORTD & 0x03);
	
	//RS: LOW -> command, RS: HIGH -> data
	if(command){
		output_low(PORTC, RS);
	}
	else{
		output_high(PORTC, RS);
	}

	// clock data into LCD
	output_low(PORTB, RW);
	output_high(PORTC, E);
	_delay_ms(1);
	output_low(PORTC, E);
}

void lcd_init() {
	// set dir of LCD pins
	set_output(DDRC, RS);
	set_output(DDRB, RW);
	set_output(DDRC, E);
	set_output(DDRD, DB0);
	set_output(DDRD, DB1);
	set_output(DDRD, DB2);
	set_output(DDRD, DB3);
	set_output(DDRD, DB4);
	set_output(DDRD, DB5);
	set_output(DDRE, DB6);
	set_output(DDRE, DB7);
	
	// set LCD pins low before trying to start the display
	output_low(PORTC, RS);
	output_low(PORTB, RW);
	output_low(PORTC, E);
	output_low(PORTD, DB0);
	output_low(PORTD, DB1);
	output_low(PORTD, DB2);
	output_low(PORTD, DB3);
	output_low(PORTD, DB4);
	output_low(PORTD, DB5);
	output_low(PORTE, DB6);
	output_low(PORTE, DB7);
	
	// start the display
	_delay_ms(100);              //Wait >40 msec after power is applied
	lcd_send_char(0x30, 0x1);    //command 0x30 = Wake up 
	_delay_ms(30);               //must wait 5ms, busy flag not available
	lcd_send_char(0x30, 0x1);    //command 0x30 = Wake up #2
	_delay_ms(10);               //must wait 160us, busy flag not available
	lcd_send_char(0x30, 0x1);    //command 0x30 = Wake up #3
	_delay_ms(10);               //must wait 160us, busy flag not available
	lcd_send_char(0x38, 0x1);    //Function set: 8-bit/2-line
	lcd_send_char(0x10, 0x1);    //Set cursor
	lcd_send_char(0x0C, 0x1);    //Display ON; Cursor ON
	lcd_send_char(0x01, 0x1);    //clear display
	lcd_send_char(0x02, 0x1);    //home cursor
	lcd_send_char(0x06, 0x1);    //Entry mode set
}
