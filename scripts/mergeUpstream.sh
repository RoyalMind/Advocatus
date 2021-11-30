#!/usr/bin/env bash

PS1="$"
basedir=`pwd`

function update {
    echo "Actualizando $basedir"
    cd "$basedir/$1"
    git fetch && git reset --hard origin/master
    cd "$basedir/$1/.."
    git add $1
}

update Waterfall

# Update submodules
echo "Actualizando sub-modulo de git"
git submodule update --recursive
