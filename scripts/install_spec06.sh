#!/bin/bash

set -e

cd "$(dirname "$0")/.."

BASE="$PWD"
SPEC_MNT=/tmp/specmnt
SPEC_DIR="$BASE/spec06"
SPEC_SUPPORT_DIR="$BASE/support_files/spec06"

mkdir -p "$SPEC_DIR"
mkdir -p "$SPEC_MNT"
sudo mount -o loop,ro cpu2006-1.2.iso "$SPEC_MNT"
trap "sudo umount $SPEC_MNT; rm -d $SPEC_MNT" EXIT

pushd "$SPEC_DIR"

tar xvf "$SPEC_MNT"/install_archives/cpu2006.tar.xz

# Install cactusADM src.alts 

curl -sSL https://www.spec.org/cpu2006/src.alt/436.cactusADM.sprintf.cpu2006.v1.2.tar.xz | tar Jxvf -

SPEC_INSTALL_ARGS=(-f)

if [ `uname -m` = "aarch64" ]; then
    # Install SPEC build tools for arm64 
    curl -sSL https://www.spec.org/cpu2006/src.alt/linux-apm-arm64-118.tar | tar xvf -

    SPEC_INSTALL_ARGS+=(-u linux-apm-arm64)
fi

./install.sh "${SPEC_INSTALL_ARGS[@]}"

# Install config and evalution support scripts

mkdir -p releval/scripts
cp "$SPEC_SUPPORT_DIR/releval.cfg" config/
ln -sf "$SPEC_SUPPORT_DIR/run.py" releval/
ln -sf "$SPEC_SUPPORT_DIR/spec_submit.sh" releval/scripts/

popd # $SPEC_DIR
