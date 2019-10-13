from machine import SPI, Pin
import time
hard_spi = SPI(1, baudrate=5000000, bits=4, sck=Pin(14), mosi=Pin(13), miso=Pin(12))

def check(byte):
	hard_spi.write(bytearray([byte]))
	print("wrote: " + str(hex(byte)))
	d = hard_spi.read(1)
	print("read: " + str(d))
