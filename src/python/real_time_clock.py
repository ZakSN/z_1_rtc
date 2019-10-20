from machine import SPI, Pin
import time

hard_spi = SPI(1, baudrate=10000, bits=4, sck=Pin(14), mosi=Pin(13), miso=Pin(12))
fpga_reset_pin = Pin(0, Pin.OUT)
epoch_set_pin = Pin(4, Pin.OUT)
epoch_reset_pin = Pin(16, Pin.OUT)

def reset_fpga():
	epoch_reset_pin.value(0)
	epoch_set_pin.value(0)
	fpga_reset_pin.value(1)
	time.sleep_ms(250)
	fpga_reset_pin.value(0)

def load_time(epoch):
	epoch_bytes = bytearray(8)
	for idx in range(8):
		epoch_bytes[-(idx+1)] = epoch & 0xFF
		epoch = epoch >> 8
	epoch_reset_pin.value(1)
	hard_spi.write(bytearray([0x01]))
	hard_spi.write(epoch_bytes)

def start_time():
	epoch_reset_pin.value(0)
	epoch_set_pin.value(1)

def print_time():
	hard_spi.write(bytearray([0x02]))
	time_bytes = hard_spi.read(8)
	time = 0;
	for idx in range(8):
		time = (time << 8) | time_bytes[idx]
	print(str(time) + " " + str(hex(time)))

def main():
	reset_fpga()
	load_time(1571588760)
	start_time()
	while 1:
		print_time()
		time.sleep_ms(500)

if (__name__ == '__main__'):
	main()
