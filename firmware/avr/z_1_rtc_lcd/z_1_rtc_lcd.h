#ifndef Z_1_RTC_LCD_H
#define Z_1_RTC_LCD_H
// LCD pins
#define RS  PC5
#define RW  PB2
#define E   PC4
#define DB0 PD2
#define DB1 PD3
#define DB2 PD4
#define DB3 PD5
#define DB4 PD6
#define DB5 PD7
#define DB6 PE0
#define DB7 PE1

#include "../z_1_rtc_constants.h"
#include <avr/io.h>
#include <util/delay.h>

#define output_low(port,pin) port &= ~(1<<pin)
#define output_high(port,pin) port |= (1<<pin)
#define set_input(portdir,pin) portdir &= ~(1<<pin)
#define set_output(portdir,pin) portdir |= (1<<pin)

void lcd_init();
void lcd_send_char(char i, char command);
void lcd_send_str(char* str);
void lcd_send_screen(char* ln0, char* ln1, char* ln2, char* ln3, char update);
#endif //Z_1_RTC_LCD_H
