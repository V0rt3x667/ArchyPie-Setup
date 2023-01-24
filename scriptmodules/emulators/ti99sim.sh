#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="ti99sim"
rp_module_desc="TI-99/SIM: Texas Instruments Home Computer Emulator"
rp_module_help="ROM Extension: .ctg\n\nCopy TI-99 Games To: ${romdir}/ti99\n\nCopy BIOS File (TI-994A.ctg) To: ${biosdir}/ti99"
rp_module_licence="GPL2 https://www.mrousseau.org/programs/ti99sim"
rp_module_repo="file ${__archive_url}/ti99sim-0.16.0.src.tar.gz"
rp_module_section="exp"
rp_module_flags=""

function depends_ti99sim() {
    local depends=(
        'clang'
        'openssl'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_ti99sim() {
    downloadAndExtract "${md_repo_url}" "${md_build}" --strip-components 1

    # Set Default Config Path(s)
    sed -e "s|\".ti99sim\"|\"ArchyPie/configs/ti99sim\"|g" -i "${md_build}/src/core/support.cpp"

    # Fix 'error: ‘strlen’ was not declared in this scope'
    sed -i "1i#include <string.h>" "${md_build}/src/core/device-support.cpp"
}

function build_ti99sim() {
    make clean
    make CC=clang CXX=clang++
    md_ret_require="${md_build}/bin/${md_id}-sdl"
}

function install_ti99sim() {
    md_ret_files=(
        'bin/catalog'
        'bin/convert-ctg'
        'bin/disk'
        'bin/dumpgrom'
        'bin/mkcart'
        'bin/ti99sim-console'
        'bin/ti99sim-sdl'
        'doc/COPYING'
        'doc/main.css'
        'doc/README.html'
    )
}

function configure_ti99sim() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/ti99/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "ti99"

        mkUserDir "${biosdir}/ti99"

        touch "${romdir}/ti99/Start.txt"
    fi

    addEmulator 1 "${md_id}" "ti99" "${md_inst}/${md_id}-sdl -f --console=${biosdir}/ti99/TI-994A.ctg"

    addSystem "ti99"
}
