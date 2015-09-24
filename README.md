# Nikon_advance_calibration

A simple R script to calibrate Nikon NEF images from astrophotography hacked Nikon DSLRs

Link to hack:
http://simeonpilgrim.com/nikon-patch/nikon-patch.html
For yet supported cameras, use USB PTP tool:
https://nikonhacker.com/viewtopic.php?f=2&t=2319

You'll need libraw unprocessed_raw to convert RAW information into TIFF. 
unprocessed_raw -T *.NEF

dcraw -4 -T -D will not work since it crops out dark pixels, which is used to facilitate accurate calibration. 

Modify the zone definition in the script accordingnally for dummy, dark and active pixels.
