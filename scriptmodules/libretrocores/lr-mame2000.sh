#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-mame2000"
rp_module_desc="MAME 0.37b5 Libretro Core"
rp_module_help="ROM Extension: .zip\n\nCopy your MAME 0.37b5 roms to either $romdir/mame-mame4all or\n$romdir/arcade"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/mame2000-libretro/master/readme.txt"
rp_module_repo="git https://github.com/libretro/mame2000-libretro master"
rp_module_section="opt"

function sources_lr-mame2000() {
    gitPullOrClone
}

function build_lr-mame2000() {
    make clean
    local params=()
    isPlatform "arm" && params+=("ARM=1" "USE_CYCLONE=1")
    isPlatform "aarch64" && params+=("IS_X86=0")
    make "${params[@]}"
    md_ret_require="$md_build/mame2000_libretro.so"
}

function install_lr-mame2000() {
    md_ret_files=(
        'mame2000_libretro.so'
        'readme.md'
        'readme.txt'
        'whatsnew.txt'
    )
}

function configure_lr-mame2000() {
    local system
    for system in arcade mame-mame4all mame-libretro; do
        mkRomDir "$system"
        defaultRAConfig "$system"
        addEmulator 0 "$md_id" "$system" "$md_inst/mame2000_libretro.so"
        addSystem "$system"
    done
}
