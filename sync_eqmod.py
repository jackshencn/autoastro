#!/usr/bin/python3

import os

solve_log = open("/tmp/solve.log")

for line in solve_log:
    if "(RA,Dec)" in line:
        break
line = line.rstrip().split('=')[1]
arr = line.split(',')
ra = float(arr[0][2:])
dec = float(arr[1].split(')')[0])

ra = ra * 24 / 360

eq_ra = os.popen("indi_getprop -1 \"EQMod Mount.ALIGNTELESCOPECOORDS.ALIGNTELESCOPE_RA\"").readlines()[0].rstrip()
eq_de = os.popen("indi_getprop -1 \"EQMod Mount.ALIGNTELESCOPECOORDS.ALIGNTELESCOPE_DE\"").readlines()[0].rstrip()

print(ra, dec, eq_ra, eq_de)


os.popen("indi_setprop \"EQMod Mount.STANDARDSYNCPOINT.STANDARDSYNCPOINT_CELESTIAL_RA=" + str(ra) + \
";STANDARDSYNCPOINT_CELESTIAL_DE=" + str(dec) + \
";STANDARDSYNCPOINT_TELESCOPE_RA=" + eq_ra + \
";STANDARDSYNCPOINT_TELESCOPE_DE=" + eq_de + \
"\"")

