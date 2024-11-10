#!/bin/bash

###### CONFIGURATION ######

BENCHMARKS=(int fp)

if [ $(uname -m) = "aarch64" ]; then
    EXPERIMENTS=(
        base                   # A baseline run without Parallaft
        parallaft_perfcounters # A profiling run to get the baseline energy consumption
        parallaft_dyncpufreq   # A Parallaft run with dynamic frequency scaling enabled
        parallaft_raft         # A RAFT run
    )
else
    EXPERIMENTS=(
        # base           # A baseline run without Parallaft
        parallaft      # A Parallaft run
        # parallaft_raft # A RAFT run
    )
fi

###########################

set -e
cd "$(dirname "$0")/.."
BASE="$PWD"
export PATH="$BASE/bin:$PATH"

function setup_permissions() {
    echo "Enabling perf counter and ptrace access"
    sudo sysctl -w kernel.yama.ptrace_scope=0 -w kernel.perf_event_paranoid=-1

    echo "Enabling cpufreq access"
    "$BASE/app/parallaft/scripts/fix_cpufreq_permissions.sh"
}

function check_memory() {
    # get free memory
    local free_mem=$(grep MemAvailable /proc/meminfo | awk '{print $2}')

    # check if it's at least 12G
    if [ $free_mem -lt 12582912 ]; then
        local free_mem_gb=$(echo "scale=2; $free_mem / 1024 / 1024" | bc)
        echo "Error: Not enough memory available. You need at least 12GB of available memory. You currently have ${free_mem_gb}GB available."
        exit 1
    fi

    local free_swap=$(grep SwapFree /proc/meminfo | awk '{print $2}')

    # check if the free swap plus free memory is at least 24G
    if [ $((free_mem + free_swap)) -lt 25165824 ]; then
        local free_mem_and_swap_gb=$(echo "scale=2; ($free_mem + $free_swap) / 1024 / 1024" | bc)
        echo "Error: Not enough memory and swap available. You need at least 24GB of available memory and swap combined. You currently have ${free_mem_and_swap_gb}GB. Consider adding swap."
        exit 1
    fi
}

function check_kernel() {
    if [ $(uname -m) != "aarch64" ]; then
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

setup_permissions
check_memory
check_kernel

RELEVAL_DIR="$BASE/spec06/releval"
REL_RUN="$RELEVAL_DIR/run.py"

echo "Starting experiment..."
echo "Raw results will be available under $RELEVAL_DIR/run"

for experiment in "${EXPERIMENTS[@]}"; do
    echo "-----------------------------------"
    echo "Starting $experiment run..."
    "$REL_RUN" --mode $experiment "${BENCHMARKS[@]}" --overwrite
done
