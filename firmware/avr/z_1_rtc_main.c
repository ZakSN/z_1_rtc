#include "z_1_rtc_constants.h"
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "z_1_rtc_lcd/z_1_rtc_lcd.h"
#include "z_1_rtc_spi/z_1_rtc_spi.h"
#include "z_1_rtc_uart/z_1_rtc_uart.h"
#include "stdbool.h"
#include "time.h"
#include "util/usa_dst.h"

char nybble_to_hex(unsigned char);

// utility function to display hex
char nybble_to_hex(unsigned char nybble) {
	if (nybble > 0xF) {
		return 'z';
	}
	char hex_lut[16] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };
	return hex_lut[nybble];
}

void uart_send_str(char* to_send) {
	for(int i=0; to_send[i]!='\0'; i++){
		USART_Transmit(to_send[i]);
	}
}

void uart_receive_str(char* buffer, int buffer_len) {
	for(int i=0; i<buffer_len; i++){
		buffer[i] = USART_Receive();
	}
}

uint64_t epoch_to_int(char* epoch){
	uint64_t int_epoch = 0;
	int_epoch = int_epoch+epoch[0];
	for (int i=1; i<8; i++) {
		int_epoch = int_epoch<<8;
		int_epoch = int_epoch+(unsigned char)epoch[i];
	}
	return int_epoch;
}

void ui64toa(uint64_t to_convert, char* buffer){
	char converted[19];
	for (int i=0; i<19; i++) {
		converted[i] = '0';
	}
	int idx = 18;
	int digit;
	char digit_to_ascii[10] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
	while(to_convert > 0){
		digit = to_convert % 10;
		converted[idx] = digit_to_ascii[digit];
		to_convert = to_convert / 10;
		idx--;
	}
	uart_send_str("\r\n");
	for (int i=0; i<19; i++) {
		buffer[i] = converted[i];
	}
	buffer[19] = '\0';
}

void get_raw_fpga_epoch(char* epoch){
	// ask the fpga for the current epoch
	output_low(PORTE, PE2);
	spi_tranceiver(0x02); // RD CMD
	for (int i=0; i<8; i++) {
		epoch[i] = spi_tranceiver(0x0);
	}

	output_high(PORTE, PE2);
}

uint64_t get_fpga_epoch(void){
	char epoch[8];
	get_raw_fpga_epoch(epoch);
	return epoch_to_int(epoch);
}

void lcd_format(char* ln0, char* ln1, char* ln2, char* ln3, char* to_format){
	int fmtidx = 0; // fmt str idx
	int lnidx = 0; // line idx
	int chidx = 0; // character idx
	char* lines[4] = {ln0, ln1, ln2, ln3};
	bool cont = true;
	while(to_format[fmtidx] != '\0' && cont == true){
		if(to_format[fmtidx] != '\n') {
			lines[lnidx][chidx] = to_format[fmtidx];
			fmtidx++;
			chidx++;
			if(chidx == 20){
				lines[lnidx][chidx] = '\0';
				lnidx++;
				chidx = 0;
			}
			if(lnidx == 4){
				cont = false;
			}
		}
		else {
			fmtidx++;
			lines[lnidx][chidx] = '\0';
			lnidx++;
			chidx = 0;
			if(lnidx == 4){
				cont = false;
			}
		}
	}
	if (cont == true){
		if((lnidx < 4) && (chidx < 21)){
			lines[lnidx][chidx] = '\0';
		}
		lnidx++;
		for(int i = lnidx; i < 4; i++){
			lines[i][0] = '\0';
		}
	}
	
	ln0[20] = '\0';
	ln1[20] = '\0';
	ln2[20] = '\0';
	ln3[20] = '\0';
}

int main(void) {

	// init interfaces
	lcd_init();
	spi_init_master();
	USART_init(UBR);

	//unselect spi
	set_output(DDRE, PE2);
	output_high(PORTE, PE2);

	lcd_send_screen(
		"Cal mode? [y/N]",
		"\0",
		"\0",
		"\0",
		0x1F
	);

	bool cal_mode = false;
	uart_send_str("cal mode? [y/N]");
	char cal_buffer[1];
	uart_receive_str(cal_buffer, 1);
	if (cal_buffer[0] == 'y' || cal_buffer[0] == 'Y') {
		cal_mode = true;
	}
	
	uint64_t fpga_epoch;
	time_t y2k_epoch;
	int UTC_offset = 0;
	char fmt_str[100];
	
	
	if (!cal_mode) {
		lcd_send_screen(
			"\0",
			"  waiting for epoch",
			"     from host",
			"\0",
			0x1F
		);

		uart_send_str("64 bit unix epoch> ");
		char epoch_buffer[8];
		uart_receive_str(epoch_buffer, 8);

		output_low(PORTE, PE2);
		spi_tranceiver(0x01); // WR CMD
		for (int i=0; i<8; i++) {
			spi_tranceiver(epoch_buffer[i]);
		}
		output_high(PORTE, PE2);
		
		lcd_send_screen(
			"\0",
			"waiting for UTC",
			"offset from host",
			"\0",
			0x1F
		);

		uart_send_str("8 bit utc offset> ");
		char utc_offset_buffer[1];
		uart_receive_str(utc_offset_buffer, 1);
		UTC_offset = (signed char)utc_offset_buffer[0];

		lcd_send_screen(
			"\0",
			"waiting for format",
			"string from host",
			"\0",
			0x1F
		);

		uart_send_str("format string> ");
		uart_receive_str(fmt_str, 100);
	}
	_delay_ms(1000);

	while (1) {
		// pause the loop
		_delay_ms(500);

		fpga_epoch = get_fpga_epoch();
		y2k_epoch = fpga_epoch - (uint64_t)UNIX_OFFSET;
		
		y2k_epoch = y2k_epoch + UTC_offset*ONE_HOUR;

		struct tm* timeptr;
		timeptr = gmtime(&y2k_epoch);

		char buffer[80];

		strftime(buffer, 80, fmt_str, timeptr);
		//uart_send_str(buffer);
		//uart_send_str("\r\n");

		char ln1[21];
		char ln2[21];
		char ln3[21];
		char ln4[21];

		lcd_format(ln1, ln2, ln3, ln4, buffer);
		
		lcd_send_screen(
			ln1,
			ln2,
			ln3,
			ln4,
			0x1F
		);

		if (cal_mode){
			char epoch[8];
			get_raw_fpga_epoch(epoch);
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
		//if (cal_mode) {
			//send the current epoch out over uart as a stripped
			//hex number followed by a newline
			for (int i=2; i<18; i++){
				USART_Transmit(hex_epoch[i]);
			}
			// need to do a carriage return and a newline for
			// terminal programs to be happy
			USART_Transmit('\r');
			USART_Transmit('\n');
		}
	}
}
