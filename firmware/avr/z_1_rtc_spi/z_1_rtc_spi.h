#ifndef Z_1_RTC_SPI_H
#define Z_1_RTC_SPI_H

/*
 * SPI pins
 * micro | fpga | function
 * PC0     pb8b   MISO
 * PC1     pb8a   SCK
 * PE2     pb5a   /SS
 * PE3     pb25b  MOSI
 */


#include "../z_1_rtc_constants.h"
#include <avr/io.h>
#include <util/delay.h>

void spi_init_master (void);
unsigned char spi_tranceiver (unsigned char data);

#endif //Z_1_RTC_SPI_H
