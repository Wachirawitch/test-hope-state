#!/usr/bin/sh

# Define the state file path
STATE_FILE="/var/lib/hope-state/state"

# Grab manufacturer information to /tmp/machine-info.json
/usr/bin/mfg-data read > /tmp/machine-info.json

# Power on GSM module
/usr/bin/gpio write 5 1
sleep 1
/usr/bin/gpio write 5 0

# Reset GSM module
/usr/bin/gpio write 2 1
sleep 1
/usr/bin/gpio write 2 0

# Environment variable path
ENV_PATH="/home/sun108/sun108-api/.env"
MACHINE_TYPE=$(grep -m 1 'MACHINE_TYPE' "$ENV_PATH" | sed -e 's/^[[:space:]]*//' | sed 's/.*=//')
MACHINE_ID=$(grep -m 1 'MACHINE_ID' "$ENV_PATH" | sed -e 's/^[[:space:]]*//' | sed 's/.*=//')

 
# Check machine state before proceeding
if [ ! -f "$STATE_FILE" ]; then
   # If the state file does not exist, assume initial setup and re-initiate display
   echo "State file not found. Re-initiating display as part of initial setup."
   echo off | tee /sys/class/drm/card0-HDMI-A-1/status
   sleep 2
   echo on | tee /sys/class/drm/card0-HDMI-A-1/status

else
   # Read the state from the file
   STATE=$(cat "$STATE_FILE")

   if [ "$STATE" = "configured" ]; then
      # If the state is "configured", check if the machine type is DP43
      if echo "$MACHINE_TYPE" | grep -q "^DP43"; then
         echo "DP43 display detected"
         echo "Re-initiate display"
         echo off | tee /sys/class/drm/card0-HDMI-A-1/status
         sleep 2
         echo on | tee /sys/class/drm/card0-HDMI-A-1/status
      fi
   elif [ "$STATE" = "factory reset" ]; then
      # If the state is "factory reset", re-initiate the display
      echo "Machine is in factory reset state. Re-initiating display."
      echo off | tee /sys/class/drm/card0-HDMI-A-1/status
      sleep 2
      echo on | tee /sys/class/drm/card0-HDMI-A-1/status
   else
      echo "Unknown state: $STATE. No action taken."
   fi
fi

echo "Done bsp-startup script."

exit 0
