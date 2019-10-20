from machine import SPI, Pin
import time
hard_spi = SPI(1, baudrate=10000, bits=8, sck=Pin(14), mosi=Pin(13), miso=Pin(12))

def check(dat):
	hard_spi.write(bytearray([0x01]))
	hard_spi.write(dat)

	hard_spi.write(bytearray([0x02]))
	d = hard_spi.read(8)

	print("read: " + str(d))
