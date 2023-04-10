#!/bin/sh

# Turn on EQ tracking
indi_setprop "EQMod Mount.DEVICE_PORT.PORT=/dev/ttyS4"
indi_setprop "EQMod Mount.CONNECTION.CONNECT=On"
indi_setprop "EQMod Mount.TELESCOPE_TRACK_STATE.TRACK_ON=On"
indi_setprop "EQMod Mount.HORIZONLIMITSLIMITGOTO.HORIZONLIMITSLIMITGOTODISABLE=On"
indi_setprop "EQMod Mount.HORIZONLIMITSONLIMIT.HORIZONLIMITSONLIMITTRACK=Off"


# Switch camera to 1080P and 0.5s exposure at high sensitivity
./set_video_fmt.sh 1 1
v4l2-ctl -d /dev/video5 --set-ctrl=vertical_blanking=50000
v4l2-ctl -d /dev/video5 --set-ctrl=analogue_gain=180,exposure=50000

sleep 2

# Take one image and convert to 8bit TIF
v4l2-ctl -d /dev/video5 --set-fmt-video=width=1932,height=1090,pixelformat=YUYV8 \
    --stream-mmap=3 --stream-to=/tmp/solve.raw --stream-count=1 --stream-poll
./yuv_tif.py

# Solve field and 
solve-field --downsample 2 --no-remove-lines --uniformize 0 --overwrite --no-plot /tmp/solve.tiff > /tmp/solve.log

./sync_eqmod.py


