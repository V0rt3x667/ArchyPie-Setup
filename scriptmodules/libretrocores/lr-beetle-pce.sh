#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-beetle-pce"
rp_module_desc="NEC PC Engine (TurboGrafx-16) & PC Engine SuperGrafx Libretro Core"
rp_module_help="ROM Extensions: .pce .ccd .cue .zip\n\nCopy your NEC PC Engine (TurboGrafx-16) & PC Engine SuperGrafx roms to $romdir/pcengine\n\nCopy the required BIOS file syscard3.pce to $biosdir"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-pce-libretro/master/COPYING"
rp_module_repo="git https://github.com/libretro/beetle-pce-libretro master"
rp_module_section="main"

function sources_lr-beetle-pce() {
    gitPullOrClone
}

function build_lr-beetle-pce() {
    make clean
    make
    md_ret_require="$md_build/mednafen_pce_libretro.so"
}

function install_lr-beetle-pce() {
    md_ret_files=(
        'mednafen_pce_libretro.so'
        'README.md'
    )
}

function configure_lr-beetle-pce() {
    mkRomDir "pcengine"
    defaultRAConfig "pcengine"

    addEmulator 1 "$md_id" "pcengine" "$md_inst/mednafen_pce_libretro.so"
    addSystem "pcengine"
}
