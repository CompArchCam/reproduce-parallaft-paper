#!/bin/bash

set -e

echo "Installing dependencies"
sudo apt-get install -y build-essential gfortran flex bison libssl-dev libelf-dev device-tree-compiler python3 python3-subprocess-tee python3-dataclasses-json python3-filelock python3-prctl python3-numpy curl gnuplot

if ! [ -x "$(command -v docker)" ]; then
    echo "Installing Docker"
    curl -sSL https://get.docker.com | sh
    sudo usermod -aG docker "$USER"
    echo "*** Please log out and log back in to use Docker without sudo ***"
fi
