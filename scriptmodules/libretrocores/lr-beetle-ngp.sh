#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-beetle-ngp"
rp_module_desc="Neo Geo Pocket & Pocket Color Libretro Core"
rp_module_help="ROM Extensions: .ngc .ngp .zip\n\nCopy Neo Geo Pocket ROMs To: ${romdir}/ngp\n\nCopy Neo Geo Pocket Color ROMs To: ${romdir}/ngpc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-ngp-libretro/master/COPYING"
rp_module_repo="git https://github.com/libretro/beetle-ngp-libretro master"
rp_module_section="main"

function sources_lr-beetle-ngp() {
    gitPullOrClone
}

function build_lr-beetle-ngp() {
    make clean
    make
    md_ret_require="${md_build}/mednafen_ngp_libretro.so"
}

function install_lr-beetle-ngp() {
    md_ret_files=('mednafen_ngp_libretro.so')
}

function configure_lr-beetle-ngp() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "ngp"
        mkRomDir "ngpc"
    fi

    defaultRAConfig "ngp"
    defaultRAConfig "ngpc"

    addEmulator 1 "${md_id}" "ngp" "${md_inst}/mednafen_ngp_libretro.so"
    addEmulator 1 "${md_id}" "ngpc" "${md_inst}/mednafen_ngp_libretro.so"

    addSystem "ngp"
    addSystem "ngpc"
}
