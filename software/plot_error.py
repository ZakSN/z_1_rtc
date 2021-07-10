#!/bin/python3
import numpy
from numpy.polynomial.polynomial import polyfit
import matplotlib.pyplot as plt
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('file', nargs='+')

for file in parser.parse_args().file:
	raw = numpy.genfromtxt(file, delimiter=',', skip_header=1)

	x = raw[:, 0]
	y = raw[:, 1]
	b, m = polyfit(x, y, 1)

	plt.plot(x, y, 'o',label='Data from '+file+
	         '\n slope of best fit [s/s]: '
        	 +str(m)+'\n vertical offset [s]: '+str(b))
	plt.plot(x, m*x + b, label='LoBF for '+file)

plt.xlabel('Normalized Unix Epoch')
plt.ylabel('(Normalized Z_1_RTC Epoch)-(Normalized Unix Epoch)')
plt.title('Normalized Unix Epoch vs. Z_1_RTC Accumulated Error')
plt.legend()
plt.show()
