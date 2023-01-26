#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-beetle-saturn"
rp_module_desc="Sega Saturn Libretro Core"
rp_module_help="ROM Extensions: .chd .cue\n\nCopy your Saturn roms to $romdir/saturn\n\nCopy the required BIOS files sega_101.bin / mpr-17933.bin to $biosdir"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-saturn-libretro/master/COPYING"
rp_module_repo="git https://github.com/libretro/beetle-saturn-libretro master"
rp_module_section="exp"
rp_module_flags=""

function sources_lr-beetle-saturn() {
    gitPullOrClone
}

function build_lr-beetle-saturn() {
    make clean
    make
    md_ret_require="$md_build/mednafen_saturn_libretro.so"
}

function install_lr-beetle-saturn() {
    md_ret_files=(
        'mednafen_saturn_libretro.so'
    )
}

function configure_lr-beetle-saturn() {
    mkRomDir "saturn"
    defaultRAConfig "saturn"

    addEmulator 1 "$md_id" "saturn" "$md_inst/mednafen_saturn_libretro.so"
    addSystem "saturn"
}
