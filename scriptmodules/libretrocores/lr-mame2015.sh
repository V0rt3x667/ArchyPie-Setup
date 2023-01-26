#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-mame2015"
rp_module_desc="MAME 0.160 Libretro Core"
rp_module_help="ROM Extension: .zip\n\nCopy your MAME roms to either $romdir/mame-libretro or\n$romdir/arcade"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/mame2015-libretro/master/docs/license.txt"
rp_module_repo="git https://github.com/libretro/mame2015-libretro master"
rp_module_section="exp"

function depends_lr-mame2015() {
    local depends=('python2')
    getDepends "${depends[@]}"
}

function sources_lr-mame2015() {
    gitPullOrClone
}

function build_lr-mame2015() {
    rpSwap on 1200
    make clean
    make
    rpSwap off
    md_ret_require="$md_build/mame2015_libretro.so"
}

function install_lr-mame2015() {
    md_ret_files=(
        'mame2015_libretro.so'
        'docs/README-original.md'
        'docs/license.txt'
    )
}

function configure_lr-mame2015() {
    local system
    for system in arcade mame-libretro; do
        mkRomDir "$system"
        defaultRAConfig "$system"
        addEmulator 0 "$md_id" "$system" "$md_inst/mame2015_libretro.so"
        addSystem "$system"
    done
}
