#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-mesen"
rp_module_desc="Nintendo NES (Famicom) & Famicom Disk System Libretro Core"
rp_module_help="ROM Extensions: .fds .nes .unf .unif .zip\n\nCopy NES ROMs To: ${romdir}/nes\nCopy Famicom ROMs To: ${romdir}/fds\nCopy BIOS File (disksys.rom) To: ${biosdir}/fds"
rp_module_licence="GPL3 https://raw.githubusercontent.com/sourmesen/mesen/master/LICENSE"
rp_module_repo="git https://github.com/libretro/Mesen master"
rp_module_section="exp"
rp_module_flags=""

function sources_lr-mesen() {
    gitPullOrClone
}

function build_lr-mesen() {
    make -C Libretro clean
    make -C Libretro
    md_ret_require="${md_build}/Libretro/mesen_libretro.so"
}

function install_lr-mesen() {
    md_ret_files=('Libretro/mesen_libretro.so')
}

function configure_lr-mesen() {
    local system
    for system in "fds" "nes"; do
        mkRomDir "${system}"
        addEmulator 0 "${md_id}" "${system}" "${md_inst}/mesen_libretro.so"
        addSystem "${system}"
    done

    defaultRAConfig "fds" "system_directory" "${biosdir}/fds"
    defaultRAConfig "nes"
}
