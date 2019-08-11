import os
import serial
import sys

def pause():
    programPause = raw_input("Press the <ENTER> key to continue...")

while True:
	ser1 = serial.Serial(str(sys.argv[1]),115200, timeout=None)
	print(ser1.name)
	s1 = ser1.read(1)

	print(ord(s1))


	ser2 = serial.Serial(str(sys.argv[2]),115200, timeout=None)
	print(ser2.name)
	s2 = ser2.write(s1)
	print(s2)
