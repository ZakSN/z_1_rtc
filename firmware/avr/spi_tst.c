#include "z_1_rtc_constants.h"
#include <avr/io.h>
#include <util/delay.h>
#include "z_1_rtc_lcd/z_1_rtc_lcd.h"

//SPI pins


int main(void) {

	lcd_init();
	lcd_send_screen(
		"first line",
		"second line",
		"third line",
		"fourth line",
		0x1F
	);
	_delay_ms(1000);
	lcd_send_screen(
		"Refresh test:",
		"lines 0-3 are static",
		"line 4 counts",
		"COUNTER: ",
		0x1F
	);

	unsigned char counter = 0;
	while (1) {
		_delay_ms(250);
		char line4[11] = {'C', 'O', 'U', 'N', 'T', 'E', 'R', ':', ' ', counter, 0x0};
		lcd_send_screen( 0x0, 0x0, 0x0, line4, 0x01 );
		counter++;
	}
}
