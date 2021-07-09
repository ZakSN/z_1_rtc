main=z_1_rtc_main
lcd=z_1_rtc_lcd/z_1_rtc_lcd
spi=z_1_rtc_spi/z_1_rtc_spi
#uart=z_1_rtc_uart/z_1_rtc_uart
cflags=-Wall -Werror -Wextra -Os
avrType=atmega328pb
programmerType=usbtiny
baud=19200

.PHONY: all flash read_fuses

all: $(main).hex

$(main).hex: $(main).c $(lcd).c $(spi).c
	avr-gcc $(cflags) -mmcu=$(avrType) -c -o $(main).o $(main).c
	avr-gcc $(cflags) -mmcu=$(avrType) -c -o $(lcd).o $(lcd).c
	avr-gcc $(cflags) -mmcu=$(avrType) -c -o $(spi).o $(spi).c
	avr-gcc $(cflags) -mmcu=$(avrType) -o $(main).elf $(main).o $(lcd).o $(spi).o
	avr-objcopy -j .text -j .data -O ihex $(main).elf $(main).hex

flash: $(main).hex
	avrdude -pm328pb -c$(programmerType) -U flash:w:$(main).hex

read_fuses:
	avrdude -pm328pb -c$(programmerType) -U lfuse:r:low_fuse_val.hex:h -U hfuse:r:high_fuse_val.hex:h -U efuse:r:ext_fuse_val.hex:h
set_fuses:
	@echo -n "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	avrdude -pm328pb -c$(programmerType) -U lfuse:w:0xfe:m -U hfuse:w:0xd9:m -U efuse:w:0xf7:m 
