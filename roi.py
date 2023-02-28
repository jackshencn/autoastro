#!/usr/bin/python

import sys
import subprocess

x = float(sys.argv[1])
y = float(sys.argv[2])

x = int(3864 * x - 648/2)
y = int(2180 * y - 480/2)

cmd = "v4l2-ctl -d /dev/video5 --set-ctrl=window_offset_x="+str(x)
subprocess.call(cmd, shell=True)
cmd = "v4l2-ctl -d /dev/video5 --set-ctrl=window_offset_y="+str(y)
subprocess.call(cmd, shell=True)

