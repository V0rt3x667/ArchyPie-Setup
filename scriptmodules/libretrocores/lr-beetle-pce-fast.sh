#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-beetle-pce-fast"
rp_module_desc="NEC PC Engine (TurboGrafx-16) Fast Libretro Core"
rp_module_help="ROM Extensions: .ccd .chd .cue .pce .sgx .zip\n\nCopy NEC PC Engine (TurboGrafx-16) ROMs To: ${romdir}/pcengine\n\nCopy BIOS File (syscard3.pce) To: ${biosdir}/pcengine"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-pce-fast-libretro/master/COPYING"
rp_module_repo="git https://github.com/libretro/beetle-pce-fast-libretro master"
rp_module_section="main"

function sources_lr-beetle-pce-fast() {
    gitPullOrClone
}

function build_lr-beetle-pce-fast() {
    make clean
    make
    md_ret_require="${md_build}/mednafen_pce_fast_libretro.so"
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

    addEmulator 1 "${md_id}" "pcengine" "${md_inst}/mednafen_pce_fast_libretro.so"

    addSystem "pcengine"
}
