A standalone Real Time Clock.

Goal is to have better standalone accuracy than the Casio F-91W wristwatch's
nominal +/- 30 s/mo. (~12ppm)

- frequency source an Oven Compensated Crystal Oscillator
- counting logic implemented in a MachXO2 FPGA (originally a 1200hc part, switched to a 2000hc part due to part shortages)
- display management time calculation implemented with an ATmega328pb
	- Was initially handled by an ESP32 running micropython

read all about the project here: https://hackaday.io/project/180005-a-digital-real-time-clock
kicad designs for the mainboard are here: https://github.com/ZakSN/z_1_rtc_pcb
