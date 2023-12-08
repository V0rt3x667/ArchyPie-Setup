#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-mesen"
rp_module_desc="Nintendo NES (Famicom) & Famicom Disk System Libretro Core"
rp_module_help="ROM Extensions: .7z .fds .nes .unf .unif .zip\n\nCopy NES ROMs To: ${romdir}/nes\n\nCopy Famicom ROMs To: ${romdir}/fds\n\nCopy BIOS File: disksys.rom To: ${biosdir}/fds\n\nCopy Famicom Disk System BIOS File: disksys.rom To: ${biosdir}/fds\n\nOPTIONAL: Copy HD Packs & Custom Palettes To The Relevant BIOS Directory"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/Mesen/master/LICENSE"
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
    local systems=(
        'fds'
        'nes'
    )

    if [[ "${md_mode}" == "install" ]]; then
        for system in "${systems[@]}"; do
            mkRomDir "${system}"
            mkUserDir "${biosdir}/${system}"
            defaultRAConfig "${system}"
        done
    fi

    for system in "${systems[@]}"; do
        addEmulator 0 "${md_id}" "${system}" "${md_inst}/mesen_libretro.so"
        addSystem "${system}"
    done
}
