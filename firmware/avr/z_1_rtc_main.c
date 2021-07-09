#include "z_1_rtc_constants.h"
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "z_1_rtc_lcd/z_1_rtc_lcd.h"
#include "z_1_rtc_spi/z_1_rtc_spi.h"


char nybble_to_hex(unsigned char);

char nybble_to_hex(unsigned char nybble) {
	if (nybble > 0xF) {
		return 'z';
	}
	char hex_lut[16] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };
	return hex_lut[nybble];
}

int main(void) {

	lcd_init();
	spi_init_master();
	set_output(DDRE, PE2);
	output_high(PORTE, PE2);

	//epoch set
	set_output(DDRB, PB1);
	output_high(PORTB, PB1);
	_delay_ms(50);
	output_low(PORTB, PB1);

	lcd_send_screen(
		"FGPA EPOCH:",
		"waiting...",
		"\0",
		"\0",
		0x1F
	);

	_delay_ms(1000);
	while (1) {
		_delay_ms(1000);
		lcd_send_screen(
			"FGPA EPOCH:",
			"loop",
			"\0",
			"\0",
			0x1F
		);
		output_low(PORTE, PE2);
		spi_tranceiver(0x02); // RD CMD
		output_high(PORTE, PE2);
		lcd_send_screen(
			"FGPA EPOCH:",
			"first spi",
			"\0",
			"\0",
			0x1F
		);
		output_low(PORTE, PE2);
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
		char hex_epoch[19] = {'0', 'x', 'F','F','F','F','F','F','F','F','F','F','F','F','F','F','F','F', 0x0};
		int idxe = 2, idxo = 3; 
		for (int i=0; i<8; i++){
			hex_epoch[idxe] = nybble_to_hex((epoch[i]>>4)&0xF);
			hex_epoch[idxo] = nybble_to_hex(epoch[i]&0xF);
			idxe+=2;
			idxo+=2;

		}
		lcd_send_screen(
			"FPGA EPOCH:",
			hex_epoch,
			"\0",
			"\0",
			0x1C
		);
	}
}
