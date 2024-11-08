#!/bin/sh

set -e

if ! [ -x "$(command -v docker)" ]; then
    echo "Installing Docker"
    curl -sSL https://get.docker.com | sh
fi

echo "Installing dependencies"
sudo apt-get install -y build-essential gfortran flex bison libssl-dev libelf-dev python3 python3-subprocess-tee python3-dataclasses-json python3-filelock python3-prctl
