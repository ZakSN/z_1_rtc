#include "z_1_rtc_constants.h"
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "z_1_rtc_lcd/z_1_rtc_lcd.h"
#include "z_1_rtc_spi/z_1_rtc_spi.h"
#include "z_1_rtc_uart/z_1_rtc_uart.h"


char nybble_to_hex(unsigned char);

// utility function to display hex
char nybble_to_hex(unsigned char nybble) {
	if (nybble > 0xF) {
		return 'z';
	}
	char hex_lut[16] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };
	return hex_lut[nybble];
}

int main(void) {

	// init interfaces
	lcd_init();
	spi_init_master();
	USART_init(UBR);

	//unselect spi
	set_output(DDRE, PE2);
	output_high(PORTE, PE2);

	/*
	//epoch set
	set_output(DDRB, PB1);
	output_high(PORTB, PB1);
	_delay_ms(50);
	output_low(PORTB, PB1);
	*/

	// wait for the crystal to warm up
	// probably unecessary
	lcd_send_screen(
		"FGPA EPOCH:",
		"starting...",
		"\0",
		"\0",
		0x1F
	);

	_delay_ms(1000);

	while (1) {
		// pause the loop
		_delay_ms(500);

		// ask the fpga for the current epoch
		output_low(PORTE, PE2);
		spi_tranceiver(0x02); // RD CMD
		char epoch[8] = {
			spi_tranceiver(0x0), // byte 0
			spi_tranceiver(0x0),
			spi_tranceiver(0x0),
			spi_tranceiver(0x0),
			spi_tranceiver(0x0),
			spi_tranceiver(0x0),
			spi_tranceiver(0x0),
			spi_tranceiver(0x0) // byte 7
		};
		output_high(PORTE, PE2);

		//convert the current epoch to a string that can be displayed
		char hex_epoch[19] = {'0', 'x', 'F','F','F','F','F','F','F','F','F','F','F','F','F','F','F','F', 0x0};
		int idxe = 2, idxo = 3; 
		for (int i=0; i<8; i++){
			hex_epoch[idxe] = nybble_to_hex((epoch[i]>>4)&0xF);
			hex_epoch[idxo] = nybble_to_hex(epoch[i]&0xF);
			idxe+=2;
			idxo+=2;

		}

		// print the current epoch on the screen
		lcd_send_screen(
			"FPGA EPOCH:",
			hex_epoch,
			"\0",
			"\0",
			0x1C
		);

		//send the current epoch out over uart as a stripped hex number
		// followed by a newline
		for (int i=2; i<18; i++){
			USART_Transmit(hex_epoch[i]);
		}
		// need to do a carriage return and a newline for terminal
		// programs to be happy
		USART_Transmit('\r');
		USART_Transmit('\n');
	}
}
