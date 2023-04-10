#!/usr/bin/python3

import sys
import os

ra = sys.argv[1].split(':')
de = sys.argv[2].split(':')

ra = float(ra[0]) + float(ra[1])/60 + float(ra[2])/3600
dec = float(de[0])
if dec >= 0:
    dec += float(de[1])/60 + float(de[2])/3600
else:
    dec -= float(de[1])/60 + float(de[2])/3600

os.popen("indi_setprop \"EQMod Mount.EQUATORIAL_EOD_COORD.RA=" + str(ra) + ";DEC=" + str(dec) + "\"")

