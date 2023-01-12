#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="capricerpi"
rp_module_desc="CapriceRPI: Amstrad CPC 464 & 6128 Emulator"
rp_module_help="ROM Extensions: .cdt .cpc .dsk\n\nCopy Amstrad CPC Games To: ${romdir}/amstradcpc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/KaosOverride/CapriceRPI/master/COPYING.txt"
rp_module_repo="git https://github.com/KaosOverride/CapriceRPI master"
rp_module_section="opt"
rp_module_flags="!all rpi"

function depends_capricerpi() {
    local depends=(
        'libpng'
        'sdl_image'
        'sdl_ttf'
        'sdl12-compat'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_capricerpi() {
    gitPullOrClone

    sed -e "s|-lpng12|-lpng|g" -i "${md_inst}/src/makefile"
}

function build_capricerpi() {
    make -C src clean
    make -C src RELEASE=TRUE
    md_ret_require="${md_build}/src/capriceRPI"
}

function install_capricerpi() {
    md_ret_files=(
        'COPYING.txt'
        'src/capriceRPI'
    )
    cp "${md_build}/README for this port.txt" "${md_inst}/README.txt"
}

function configure_capricerpi() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "amstradcpc"
    fi

    addEmulator 0 "${md_id}" "amstradcpc" "${md_inst}/capriceRPI %ROM%"

    addSystem "amstradcpc"
}
