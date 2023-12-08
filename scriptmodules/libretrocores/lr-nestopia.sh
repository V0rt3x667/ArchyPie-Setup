#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-nestopia"
rp_module_desc="Nintendo NES (Famicom) & Famicom Disk System Libretro Core"
rp_module_help="ROM Extensions: .fds .nes .unf .unif .zip\n\nCopy NES ROMs To: ${romdir}/nes\n\nCopy Famicom Disk System ROMs To: ${romdir}/fds\n\nCopy BIOS File: disksys.rom To: ${biosdir}/fds"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/nestopia/master/COPYING"
rp_module_repo="git https://github.com/libretro/nestopia master"
rp_module_section="main"

function sources_lr-nestopia() {
    gitPullOrClone
}

function build_lr-nestopia() {
    rpSwap on 512
    make -C libretro clean
    make -C libretro
    rpSwap off
    md_ret_require="${md_build}/libretro/nestopia_libretro.so"
}

function install_lr-nestopia() {
    md_ret_files=('libretro/nestopia_libretro.so')
}

function configure_lr-nestopia() {
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
        if [[ "${system}" == "nes" ]]; then
            def=0
        fi
        addEmulator "${def}" "${md_id}" "${system}" "${md_inst}/nestopia_libretro.so"
        addSystem "${system}"
    done
}
