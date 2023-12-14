#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-virtualjaguar"
rp_module_desc="Atari Jaguar Libretro Core"
rp_module_help="ROM Extensions: .abs .bin .cof .j64 .jag .prg .rom .zip\n\nCopy Atari Jaguar ROMs To: ${romdir}/atarijaguar"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/virtualjaguar-libretro/master/docs/GPLv3"
rp_module_repo="git https://github.com/libretro/virtualjaguar-libretro master"
rp_module_section="exp"
rp_module_flags=""

function sources_lr-virtualjaguar() {
    gitPullOrClone
}

function build_lr-virtualjaguar() {
    make clean
    make
    md_ret_require="${md_build}/virtualjaguar_libretro.so"
}

function install_lr-virtualjaguar() {
    md_ret_files=('virtualjaguar_libretro.so')
}

function configure_lr-virtualjaguar() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "atarijaguar"
        defaultRAConfig "atarijaguar"
    fi

    addEmulator 1 "${md_id}" "atarijaguar" "${md_inst}/virtualjaguar_libretro.so"

    addSystem "atarijaguar"
}
