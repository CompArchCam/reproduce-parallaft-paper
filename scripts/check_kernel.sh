#!/bin/bash

set -e

# Check if the version ends with -parallaft
echo "Checking kernel version..."

KERN_VER=`uname -r`
if [[ $KERN_VER == *"-parallaft" ]]; then
    echo "Kernel version is OK"
else
    echo "Error: Kernel version is not correct, got $KERN_VER, expecting one ending with -parallaft"
    exit 1
fi

# Check if we can read hwmon sensors
echo "Checking power sensor..."

HWMON=(/sys/bus/platform/devices/macsmc_hwmon/hwmon/hwmon*)
if [ -d $HWMON ]; then
    cat "$HWMON"/power*_label | fgrep "CPU P-cores Power" >/dev/null
    echo "Power sensor is OK"
else
    echo "Error: macsmc_hwmon is not present"
    exit 1
fi
