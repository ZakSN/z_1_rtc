#!/bin/python3
import serial
import time
import datetime

def get_z_1_rtc_epoch(ser):
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

def cal_mode(ser):
	logfile = open("error_log.txt", "w")

	print("normalized unix epoch [s], accumulated error [s]")
	logfile.write("normalized unix epoch [s], accumulated error [s]" + "\n")

	z_epoch_start = get_z_1_rtc_epoch(ser)
	u_epoch_start = int(time.time())

	while(True):
		try:
			unix_epoch = int(time.time())
			z_1_rtc_epoch = get_z_1_rtc_epoch(ser)
			normalized_z_epoch = z_1_rtc_epoch - z_epoch_start
			normalized_u_epoch = unix_epoch - u_epoch_start
			accumulated_error = normalized_z_epoch - normalized_u_epoch
			print(str(normalized_u_epoch) + ", " + str(accumulated_error))
			logfile.write(str(normalized_u_epoch) + ", " + str(accumulated_error) + "\n")
		except KeyboardInterrupt:
			print("\nclosing log")
			logfile.close()
			exit()

def main():
	#TODO
	ser = serial.Serial('/dev/ttyUSB0')
	cm = input("Cal Mode [y/N] ")
	if cm == 'y' or cm == 'Y':
		ser.write(bytes('y'.encode('ascii')))
		cal_mode(ser)
	else:
		ser.write(bytes('n'.encode('ascii')))
	
	time.sleep(2)

	unix_epoch = int(time.time())
	print(unix_epoch)
	unix_epoch = bytes.fromhex("%0.16X" % unix_epoch)
	ser.write(unix_epoch)
	
	time.sleep(1)

	utc_offset = time.localtime().tm_gmtoff
	utc_offset = int(utc_offset/3600)
	ser.write(utc_offset.to_bytes(1, byteorder='big', signed=True))

	time.sleep(1)
	
	local_tz = datetime.datetime.now(datetime.timezone.utc).astimezone().tzinfo
	default_fmt_str = "%a %d %b %Y\n%I:%M.%S %p\n"+str(local_tz)+" (UTC "+str(utc_offset)+")"
	fmt_str = input("enter display format string [leave blank for default] ")
	if fmt_str == "":
		fmt_str = default_fmt_str
	fmt_str = fmt_str
	while(len(fmt_str) < 100):
		fmt_str = fmt_str + '\0'
	print(fmt_str)
	ser.write(bytes(fmt_str.encode('ascii')))
	
	

if __name__ == "__main__":
	main()
