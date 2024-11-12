#!/bin/bash

set -e

function check_kernel() {
    if [ $(uname -m) != "aarch64" ]; then
        echo "Not on aarch64, skipping check"
        return
    fi

    # Check if the version ends with -parallaft
    echo "Checking kernel version..."

    local kern_ver=$(uname -r)
    if [[ $kern_ver == *"-parallaft" ]]; then
        echo "Kernel version is OK"
    else
        echo "Error: Kernel version is not correct, got $kern_ver, expecting one ending with -parallaft."
        exit 1
    fi

    # Check if we can read hwmon sensors
    echo "Checking power sensor..."

    local hwmon=(/sys/bus/platform/devices/macsmc_hwmon/hwmon/hwmon*)
    if [ -d $hwmon ]; then
        cat "$hwmon"/power*_label | fgrep "CPU P-cores Power" >/dev/null
        echo "Power sensor is OK"
    else
        echo "Error: macsmc_hwmon is not present"
        exit 1
    fi
}

check_kernel
