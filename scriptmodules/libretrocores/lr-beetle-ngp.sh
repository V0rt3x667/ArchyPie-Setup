#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-beetle-ngp"
rp_module_desc="Neo Geo Pocket & Pocket Color Libretro Core"
rp_module_help="ROM Extensions: .ngc .ngp .zip\n\nCopy your Neo Geo Pocket roms to $romdir/ngp\n\nCopy your Neo Geo Pocket Color roms to $romdir/ngpc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-ngp-libretro/master/COPYING"
rp_module_repo="git https://github.com/libretro/beetle-ngp-libretro master"
rp_module_section="main"

function sources_lr-beetle-ngp() {
    gitPullOrClone
}

function build_lr-beetle-ngp() {
    make clean
    make
    md_ret_require="$md_build/mednafen_ngp_libretro.so"
}

function install_lr-beetle-ngp() {
    md_ret_files=(
        'mednafen_ngp_libretro.so'
    )
}

function configure_lr-beetle-ngp() {
    local system
    for system in ngp ngpc; do
        mkRomDir "$system"
        defaultRAConfig "$system"
        addEmulator 1 "$md_id" "$system" "$md_inst/mednafen_ngp_libretro.so"
        addSystem "$system"
    done

}
