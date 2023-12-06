#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-fceumm"
rp_module_desc="Nintendo NES & Famicom Libretro Core"
rp_module_help="ROM Extensions: .fds .nes .unf .unif .zip\n\nCopy NES ROMs To: ${romdir}/nes\n\nCopy Famicom Disk System Games To: ${romdir}/fds\n\nCopy Famicom Disk System BIOS File: disksys.rom To: ${biosdir}/fds\n\nOPTIONAL: Copy NES Game Genie File: gamegenie.nes To: ${biosdir}/nes"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/libretro-fceumm/master/Copying"
rp_module_repo="git https://github.com/libretro/libretro-fceumm master"
rp_module_section="main"

function sources_lr-fceumm() {
    gitPullOrClone
}

function build_lr-fceumm() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro

    md_ret_require="${md_build}/fceumm_libretro.so"
}

function install_lr-fceumm() {
    md_ret_files=('fceumm_libretro.so')
}

function configure_lr-fceumm() {
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
        local def=1
        if [[ "${system}" == "fds" ]]; then
            def=0
        fi
        addEmulator "${def}" "${md_id}" "${system}" "${md_inst}/fceumm_libretro.so"
        addSystem "${system}"
    done
}
