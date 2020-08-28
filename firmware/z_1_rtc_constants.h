#ifndef Z_1_RTC_CONSTANTS_H
#define Z_1_RTC_CONSTANTS_H

#define F_CPU 8000000UL

// Some macros that make the code more readable
// (Adafruit example)
#define output_low(port,pin) port &= ~(1<<pin)
#define output_high(port,pin) port |= (1<<pin)
#define set_input(portdir,pin) portdir &= ~(1<<pin)
#define set_output(portdir,pin) portdir |= (1<<pin)

#endif //Z_1_RTC_CONSTANTS_H
