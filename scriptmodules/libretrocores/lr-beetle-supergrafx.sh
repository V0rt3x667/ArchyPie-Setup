#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-beetle-supergrafx"
rp_module_desc="NEC PC Engine SuperGrafx Fast Libretro Core"
rp_module_help="ROM Extensions: .pce .ccd .cue .zip\n\nCopy your PC Engine SuperGrafx roms to $romdir/pcengine\n\nCopy the required BIOS file syscard3.pce to $biosdir"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-supergrafx-libretro/master/COPYING"
rp_module_repo="git https://github.com/libretro/beetle-supergrafx-libretro master"
rp_module_section="main"

function sources_lr-beetle-supergrafx() {
    gitPullOrClone
}

function build_lr-beetle-supergrafx() {
    make clean
    make
    md_ret_require="$md_build/mednafen_supergrafx_libretro.so"
}

function install_lr-beetle-supergrafx() {
    md_ret_files=(
        'mednafen_supergrafx_libretro.so'
    )
}

function configure_lr-beetle-supergrafx() {
    mkRomDir "pcengine"
    defaultRAConfig "pcengine"

    addEmulator 0 "$md_id" "pcengine" "$md_inst/mednafen_supergrafx_libretro.so"
    addSystem "pcengine"
}
