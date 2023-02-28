#!/bin/bash

ch=$1
v4l2_ch="0"
if [ "$ch" = "1" ] ; then
    v4l2_ch="5"
fi

if [ "$2" = "0" ] ; then
    w="3864"
    h="2180"
elif [ "$2" = "1" ]; then
    w="1932"
    h="1090"
else
    w="648"
    h="480"
fi

fmt="${w}x${h}"

mode=${3-0}
if [ "$mode" = "1" ] ; then
    output_fmt="SRGGB12_1X12"
else
    output_fmt="YUYV8_2X8"
fi

media-ctl -d /dev/media${ch} --set-v4l2 '8:0[fmt:SRGGB12_1X12/'"${fmt}"']'
media-ctl -d /dev/media${ch} --set-v4l2 '1:0[fmt:SRGGB12_1X12/'"${fmt}"']'
media-ctl -d /dev/media${ch} --set-v4l2 '1:0[crop:(0,0)/'"${fmt}"']'
media-ctl -d /dev/media${ch} --set-v4l2 '1:2[fmt:'"${output_fmt}"'/'"${fmt}"']'
media-ctl -d /dev/media${ch} --set-v4l2 '1:2[crop:(0,0)/'"${fmt}"']'
v4l2-ctl -d /dev/video${v4l2_ch} --set-fmt-video=width=${w},height=${h} --set-crop=width=${w},height=${h}
