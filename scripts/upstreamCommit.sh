#!/usr/bin/env bash
(
set -e
PS1="$"

function changelog() {
    base=$(git ls-tree HEAD $1  | cut -d' ' -f3 | cut -f1)
    cd $1 && git log --oneline ${base}...HEAD
}
advocatus=$(changelog Waterfall)

updated=""
logsuffix=""
if [ ! -z "$advocatus" ]; then
    logsuffix="$logsuffix\n\nAdvocatus Changes:\n$advocatus"
    if [ -z "$updated" ]; then updated="Waterfall"; else updated="$updated/Waterfall"; fi
fi
disclaimer="Upstream ha publicado actualizaciones que parecen aplicarse y compilarse correctamente. \nEsta actualización no ha sido probada por PaperMC o RoyalMind y, como con CUALQUIER actualización, haga sus propias pruebas."

if [ ! -z "$1" ]; then
    disclaimer="$@"
fi

log="${UP_LOG_PREFIX}Actualizado Upstream ($updated)\n\n${disclaimer}${logsuffix}"

echo -e "$log" | git commit -F -

) || exit 1
