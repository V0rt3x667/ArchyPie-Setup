#!/bin/bash

emulator="./EMULATOR"
rom="$1"
shift
params=("$@")

pushd "${0%/*}" >/dev/null || exit
if [[ -z "${rom}" ]]; then
    "${emulator}" "${params[@]}"
else
    source "/opt/archypie/lib/archivefuncs.sh"

    archiveExtract "${rom}" ".a52 .atr .bas .bin .car .dcm .xex .xfd"

    # Check For Successful Extraction
    if [[ $? == 0 ]]; then
        rom="${arch_files[0]}"
    fi

    "${emulator}" "${rom}" "${params[@]}"
    archiveCleanup
fi
popd || exit
