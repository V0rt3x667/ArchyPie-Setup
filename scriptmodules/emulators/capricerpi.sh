#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="capricerpi"
rp_module_desc="CapriceRPI - Amstrad CPC 464 & 6128 Emulator"
rp_module_help="ROM Extensions: .cdt .cpc .dsk\n\nCopy your Amstrad CPC games to $romdir/amstradcpc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/KaosOverride/CapriceRPI/master/COPYING.txt"
rp_module_repo="git https://github.com/KaosOverride/CapriceRPI.git master"
rp_module_section="opt"
rp_module_flags="!all rpi"

function depends_capricerpi() {
    local depends=(
        'libpng'
        'sdl'
        'sdl_image'
        'sdl_ttf'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_capricerpi() {
    gitPullOrClone
    sed "s|-lpng12|-lpng|" -i "$md_inst/src/makefile"
}

function build_capricerpi() {
    make -C src clean
    make -C src RELEASE=TRUE
    md_ret_require="$md_build/src/capriceRPI"
}

function install_capricerpi() {
    cp -Rv "$md_build/"{README*.txt,COPYING.txt} "$md_inst/"
    cp -Rv "$md_build/src/capriceRPI" "$md_inst/"
}

function configure_capricerpi() {
    mkRomDir "amstradcpc"

    addEmulator 0 "$md_id" "amstradcpc" "$md_inst/capriceRPI %ROM%"
    addSystem "amstradcpc"
}
