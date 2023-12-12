#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-prosystem"
rp_module_desc="Atari 7800 ProSystem Libretro Core"
rp_module_help="ROM Extensions: .a78 .bin .cdf .zip\n\nCopy Atari 7800 ROMs To: ${romdir}/atari7800\n\nOPTIONAL: Copy BIOS Files: 7800 BIOS (E).rom & 7800 BIOS (U).rom To: ${biosdir}/atari7800"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/prosystem-libretro/master/License.txt"
rp_module_repo="git https://github.com/libretro/prosystem-libretro master"
rp_module_section="main"

function sources_lr-prosystem() {
    gitPullOrClone
}

function build_lr-prosystem() {
    make clean
    make
    md_ret_require="${md_build}/prosystem_libretro.so"
}

function install_lr-prosystem() {
    md_ret_files=('prosystem_libretro.so')
}

function configure_lr-prosystem() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "atari7800"
        mkUserDir "${biosdir}/atari7800"
        defaultRAConfig "atari7800"
    fi

    addEmulator 1 "${md_id}" "atari7800" "${md_inst}/prosystem_libretro.so"

    addSystem "atari7800"
}
