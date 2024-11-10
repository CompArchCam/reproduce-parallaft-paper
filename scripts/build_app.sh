#!/bin/bash

set -e
cd "$(dirname "$0")/.."

echo "Building Parallaft"
mkdir -p bin
docker build app --output bin
