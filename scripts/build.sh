#!/usr/bin/env bash

echo "Aplicando archivos patch..."

git submodule update --recursive --init && ./scripts/applyPatches.sh
if [ "$1" == "--jar" ]; then
    pushd Advocatus-Proxy
    mvn clean package -T 8
fi
