#!/bin/bash

OPEN_SHUTTER="EQMod Mount.SNAPPORT2.SNAPPORT2_ON=On"
CLOSE_SHUTTER="EQMod Mount.SNAPPORT2.SNAPPORT2_OFF=On"


exposeSensor() {
  indi_setprop "$OPEN_SHUTTER"
  sleep $1
  indi_setprop "$CLOSE_SHUTTER"
}


closeShutter() {
  indi_setprop "$CLOSE_SHUTTER"

  # We call closeShutter first in the script below.
  # It can double as a test to make sure the parameter exists.
  if [ $? -ne 0 ]
  then
    echo
    echo "Could not access the snap port!"
    echo
    exit 1
  fi
}


# Print output prefixed with time.
function log_this() {
  echo "$(date "+%T.%3N") -- $@"
}


# Print hours, minutes, seconds....
convertSeconds() {
  h=$(bc <<< "${1}/3600")
  m=$(bc <<< "(${1}%3600)/60")
  s=$(bc <<< "${1}%60")
  printf "%02d:%02d:%04.1f" $h $m $s
}


# Ctrl-C handler for clean shutdown
exitScript() {
  echo
  log_this "Done"
  closeShutter
  exit 0
}

trap exitScript SIGINT


# Make sure the shutter is closed at the start.
closeShutter


# Main Loop
COUNT=300
EXPOSURE="${1-180}"
for i in $(seq 1 ${COUNT})
do
  echo "Frame ${i}/${COUNT} for ${EXPOSURE}"
  exposeSensor $EXPOSURE
  sleep 1
done

# We won't hit this when using the infinite loop above. 
exitScript
