# Autoastro

## NikonHacker Astrophotography Patch Calibration

Use `Advanced_calibration-Nikon.ipynb` to calibrate Nikon NEF images from astrophotography hacked Nikon DSLRs

Link to hack:
http://simeonpilgrim.com/nikon-patch/nikon-patch.html
For yet supported cameras, use USB PTP tool:
https://nikonhacker.com/viewtopic.php?f=2&t=2319

For cameras other than D5100/D7000/D600/610/D800/D800E, modify the zone definition in the script accordingnally for dummy, dark and active pixels.

## Alignment and Goto

Run `indiserver | indi_eqmod_telescope` in background.
Use `one_star_align.sh` for alignment.
