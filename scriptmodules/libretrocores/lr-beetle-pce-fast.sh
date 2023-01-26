#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-beetle-pce-fast"
rp_module_desc="NEC PC Engine (TurboGrafx-16) Fast Libretro Core"
rp_module_help="ROM Extensions: .pce .ccd .cue .zip\n\nCopy your NEC PC Engine (TurboGrafx-16) roms to $romdir/pcengine\n\nCopy the required BIOS file syscard3.pce to $biosdir"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-pce-fast-libretro/master/COPYING"
rp_module_repo="git https://github.com/libretro/beetle-pce-fast-libretro master"
rp_module_section="main"

function _update_hook_lr-beetle-pce-fast() {
    # move from old location and update emulators.cfg
    renameModule "lr-mednafen-pce-fast" "lr-beetle-pce-fast"
}

function sources_lr-beetle-pce-fast() {
    gitPullOrClone
}

function build_lr-beetle-pce-fast() {
    make clean
    make
    md_ret_require="$md_build/mednafen_pce_fast_libretro.so"
}

function install_lr-beetle-pce-fast() {
    md_ret_files=(
        'mednafen_pce_fast_libretro.so'
        'README.md'
    )
}

function configure_lr-beetle-pce-fast() {
    mkRomDir "pcengine"
    defaultRAConfig "pcengine"

    addEmulator 1 "$md_id" "pcengine" "$md_inst/mednafen_pce_fast_libretro.so"
    addSystem "pcengine"
}
