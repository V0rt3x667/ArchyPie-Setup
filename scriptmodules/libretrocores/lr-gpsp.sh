#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-gpsp"
rp_module_desc="Nintendo Game Boy Advance Libretro Core"
rp_module_help="ROM Extensions: .gba .zip\n\nCopy your Game Boy Advance roms to $romdir/gba\n\nCopy the required BIOS file gba_bios.bin to $biosdir"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/gpsp/master/COPYING"
rp_module_repo="git https://github.com/libretro/gpsp master"
rp_module_section="opt arm=main"
rp_module_flags="!all arm"

function sources_lr-gpsp() {
    gitPullOrClone
}

function build_lr-gpsp() {
    rpSwap on 512
    local params=()
    isPlatform "arm" && params+=(platform=armv)
    make "${params[@]}" clean
    make "${params[@]}"
    rpSwap off
    md_ret_require="$md_build/gpsp_libretro.so"
}

function install_lr-gpsp() {
    md_ret_files=(
        'gpsp_libretro.so'
        'COPYING'
        'readme.txt'
        'game_config.txt'
    )
}

function configure_lr-gpsp() {
    mkRomDir "gba"
    defaultRAConfig "gba"

    addEmulator 0 "$md_id" "gba" "$md_inst/gpsp_libretro.so"
    addSystem "gba"
}
