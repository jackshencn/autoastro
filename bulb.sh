#!/bin/bash

gphoto2 --set-config /main/other/d031=0 \
 --set-config /main/other/d031=1

EXPOSURE=${1-180}
COUNT=${2-100}

for i in $(seq 1 ${COUNT})
do
echo "Begin Exposure $i"
gphoto2 --set-config capturetarget=0 --set-config bulb=1 --wait-event=${EXPOSURE}s --set-config bulb=0 --wait-event-and-download=2s
#gphoto2 --set-config bulb=1 --wait-event=${EXPOSURE}s --set-config capturetarget=1 --set-config bulb=0 --wait-event=CAPTURECOMPLETE
sleep 1
done

