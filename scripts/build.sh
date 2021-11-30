#!/usr/bin/env bash

echo "Construyendo artefactos..."

git submodule update --recursive --init && ./scripts/applyPatches.sh
if [ "$1" == "--jar" ]; then
    pushd Advocatus-Proxy
    mvn clean package
fi
