#!/bin/python3
import serial
import time

ser = serial.Serial('/dev/ttyUSB0')

def get_z_1_rtc_epoch():
	no_epoch = True
	while(no_epoch):
		# get an epoch string out of the clock, strip off all of the extraneous
		# bits and convert from hex to a nice clean int
		z_1_rtc_epoch_bytes = ser.readline()
		z_1_rtc_epoch = ''.join(map(chr, z_1_rtc_epoch_bytes))
		z_1_rtc_epoch = z_1_rtc_epoch.replace("\r\n", "")
		z_1_rtc_epoch = z_1_rtc_epoch.replace("\0", "")
		z_1_rtc_epoch = z_1_rtc_epoch.replace("\n", "")
		try:
			z_1_rtc_epoch = int(z_1_rtc_epoch, 16)
			no_epoch = False
		except ValueError:
			# sometimes the serial port is out of sync, and you don't get
			# a valid number, just ignore this case
			pass
	return z_1_rtc_epoch

z_epoch_start = get_z_1_rtc_epoch()
u_epoch_start = int(time.time())

print("starting epoch [s]: " + str(u_epoch_start))
print("normalized unix epoch [s], accumulated error [s]")
while(True):
	unix_epoch = int(time.time())
	z_1_rtc_epoch = get_z_1_rtc_epoch()
	normalized_z_epoch = z_1_rtc_epoch - z_epoch_start
	normalized_u_epoch = unix_epoch - u_epoch_start
	accumulated_error = normalized_z_epoch - normalized_u_epoch
	print(str(normalized_u_epoch) + ", " + str(accumulated_error))
