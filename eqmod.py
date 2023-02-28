import serial
import sys

cmd = ':' + sys.argv[1] + '\r'
ser = serial.Serial('/dev/ttyUSB0', 9600, timeout=0.1)
ser.write(cmd.encode('ascii'))

res = ser.read(20)

print(res)

