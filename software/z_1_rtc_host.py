#!/bin/python3
import serial
import time

ser = serial.Serial('/dev/ttyUSB0')
logfile = open("error_log.txt", "w")

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

print("normalized unix epoch [s], accumulated error [s]")
logfile.write("normalized unix epoch [s], accumulated error [s]" + "\n")

z_epoch_start = get_z_1_rtc_epoch()
u_epoch_start = int(time.time())

while(True):
	try:
		unix_epoch = int(time.time())
		z_1_rtc_epoch = get_z_1_rtc_epoch()
		normalized_z_epoch = z_1_rtc_epoch - z_epoch_start
		normalized_u_epoch = unix_epoch - u_epoch_start
		accumulated_error = normalized_z_epoch - normalized_u_epoch
		print(str(normalized_u_epoch) + ", " + str(accumulated_error))
		logfile.write(str(normalized_u_epoch) + ", " + str(accumulated_error) + "\n")
	except KeyboardInterrupt:
		print("\nclosing log")
		logfile.close()
		exit()
