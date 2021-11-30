#!/usr/bin/env bash

PS1="$"
basedir="$(cd "$1" && pwd -P)"
workdir="$basedir/work"
gpgsign="$(git config commit.gpgsign || echo "false")"
echo "Reconstrucción de proyectos basados.... "

function enableCommitSigningIfNeeded {
    if [[ "$gpgsign" == "true" ]]; then
        echo "Reactivación de la firma GPG"
        # Sí, esto tiene que ser global
        git config --global commit.gpgsign true
    fi
}

function applyPatch {
    what=$1
    what_name=$(basename "$what")
    target=$2
    branch=$3

    cd "$basedir/$what"
    git fetch
    git branch -f upstream "$branch" >/dev/null

    cd "$basedir"
    if [ ! -d  "$basedir/$target" ]; then
        git clone "$what" "$target"
    fi
    cd "$basedir/$target"

    echo "Restableciendo $target a $what_name..."
    git remote rm upstream > /dev/null 2>&1
    git remote add upstream "$basedir/$what" >/dev/null 2>&1
    git checkout master 2>/dev/null || git checkout -b master
    git fetch upstream >/dev/null 2>&1
    git reset --hard upstream/upstream

    echo "  Aplicando parches a $target..."

    git am --abort >/dev/null 2>&1
    git am --3way --ignore-whitespace "$basedir/${what_name}-Patches/"*.patch
    if [ "$?" != "0" ]; then
        echo "  Algo no se aplicó correctamente a $target."
        echo "  Por favor, revise los detalles anteriores y complete la solicitud."
        echo "  guarda los cambios con rebuildPatches.sh"
        enableCommitSigningIfNeeded
        exit 1
    else
        echo "  Patches applied cleanly to $target"
    fi
}

# Desactive la firma GPG antes de AM, ralentiza las cosas y no funciona bien.
# Tampoco hay ninguna razón racional o lógica para hacerlo para estos AM sub-repo.
# Calma niños, se vuelve a habilitar (si es necesario) inmediatamente después, pasa o no pasa.
if [[ "$gpgsign" == "true" ]]; then
    echo "Desactivación _temporal_ de la firma GPG"
    git config --global commit.gpgsign false
fi

# Apply waterfall patches
basedir=$basedir/Waterfall
pushd Waterfall
applyPatch BungeeCord Waterfall-Proxy HEAD
popd
basedir=$(dirname "$basedir")

# Apply Advocatus patches
applyPatch Waterfall/Waterfall-Proxy Advocatus-Proxy HEAD

enableCommitSigningIfNeeded
