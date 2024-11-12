#!/bin/bash

set -e

cd "$(dirname "$0")/.."
BASE="$PWD"

function check_cpu() {
    local cpu_vendor=$(lscpu | grep '^Vendor ID:' | awk '{print $NF}')
    if [ "$cpu_vendor" != "Apple" ]; then
        echo "Error: only Apple CPUs are supported"
        exit 1
    fi
}

check_cpu
mkdir -p kernel
pushd kernel

git clone https://github.com/mbyzhang/linux-asahi.git --branch relsh --single-branch --depth=1
cp "$BASE/support_files/asahi_kernel/config" linux-asahi/.config

pushd linux-asahi

# Build the Linux kernel
make -j8 LOCALVERSION=-parallaft 

# Install the modules
sudo make modules_install INSTALL_MOD_STRIP=1

# Install the device tree blobs
KERN_RELEASE=`make kernelrelease`
echo "Installing device tree blobs for kernel $KERN_RELEASE"
DTB_DIR="/lib/firmware/$KERN_RELEASE/device-tree/apple"
mkdir -p "$DTB_DIR"
sudo cp -r arch/arm64/boot/dts/apple/*.dtb "$DTB_DIR"
sudo update-m1n1

# Install the kernel
sudo make install

popd
popd

echo "Done. Please reboot your machine"
