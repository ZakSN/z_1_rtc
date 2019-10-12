from machine import SPI, Pin
import time
hard_spi = SPI(1, 500000, bits=4, sck=Pin(14), mosi=Pin(13), miso=Pin(12))

while(1):
	for pattern in range(16):
		hard_spi.write(bytearray([pattern]))
		time.sleep(1)
