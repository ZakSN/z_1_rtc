#ifndef Z_1_RTC_UART_H
#define Z_1_RTC_UART_H

#include "../z_1_rtc_constants.h"
#include <avr/io.h>
#include <util/delay.h>

// Define baud rate
#define USART_BAUDRATE 9600
#define UBR F_CPU/16/USART_BAUDRATE - 1

void USART_init(unsigned int ubr);
void USART_Transmit(unsigned char data);
unsigned char USART_Receive( void );

#endif //Z_1_RTC_UART_H
