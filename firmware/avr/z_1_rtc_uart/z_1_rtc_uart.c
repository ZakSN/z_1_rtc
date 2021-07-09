#include "z_1_rtc_uart.h"

void USART_init(unsigned int ubr) {
	//load usart baud rate register with uart baud rate
	UBRR0H = (unsigned char) (ubr >> 8);
	UBRR0L = (unsigned char) ubr;
	// set RX and TX flags in uart control and status register
	UCSR0B = (1<<RXEN0)|(1<<TXEN0);
	// set stop bits (1) and character size (8) in the UCSR
	UCSR0C = (0<<USBS0)|(3<<UCSZ00);
}

void USART_Transmit( unsigned char data ) {
	/* Wait for empty transmit buffer */
	while ( !( UCSR0A & (1<<UDRE0)) );
	/* Put data into buffer, sends the data */
	UDR0 = data;
}


unsigned char USART_Receive( void ) {
	// Wait for data to be received
	while ( !(UCSR0A & (1<<RXC0)) );
	// Get and return received data from buffer
	return UDR0;
}
