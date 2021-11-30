#!/usr/bin/env bash

(
PS1="$"
basedir="$(cd "$1" && pwd -P)"
workdir="$basedir/work"
echo "Reconstruyendo archivos de parche desde el estado actual de la bifurcación..."
git config core.safecrlf false

function cleanupPatches {
    cd "$1"
    for patch in *.patch; do
        echo "Aplicando parche: $patch"
        gitver=$(tail -n 2 "$patch" | grep -ve "^$" | tail -n 1)
        diffs=$(git diff --staged "$patch" | grep -E "^(\+|\-)" | grep -Ev "(From [a-z0-9]{32,}|\-\-\- a|\+\+\+ b|.index)")

        testver=$(echo "$diffs" | tail -n 2 | grep -ve "^$" | tail -n 1 | grep "$gitver")
        if [ "x$testver" != "x" ]; then
            diffs=$(echo "$diffs" | sed 'N;$!P;$!D;$d')
        fi

        if [ "x$diffs" == "x" ] ; then
            git reset HEAD "$patch" >/dev/null
            git checkout -- "$patch" >/dev/null
        fi
    done
}

function savePatches {
    what=$1
    what_name=$(basename "$what")
    target=$2
    echo "Formateando parches para $what..."

    cd "$basedir/${what_name}-Patches/"
    if [ -d "$basedir/$target/.git/rebase-apply" ]; then
        # en medio de un rebase, sé más inteligente
        echo "REBASE DETECTADO - GUARDADO PARCIAL"
        last=$(cat "$basedir/$target/.git/rebase-apply/last")
        next=$(cat "$basedir/$target/.git/rebase-apply/next")
        for i in $(seq -f "%04g" 1 1 $last)
        do
            if [ $i -lt $next ]; then
                rm ${i}-*.patch
            fi
        done
    else
        rm -rf *.patch
    fi

    cd "$basedir/$target"

    git format-patch --no-stat -N -o "$basedir/${what_name}-Patches/" upstream/upstream >/dev/null
    cd "$basedir"
    git add -A "$basedir/${what_name}-Patches"
    cleanupPatches "$basedir/${what_name}-Patches"
    echo "  Parches guardados por $what a $what_name-Patches/"
}

savePatches "Waterfall/Waterfall-Proxy" "Advocatus-Proxy"
)