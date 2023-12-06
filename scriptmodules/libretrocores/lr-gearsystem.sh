#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-gearsystem"
rp_module_desc="Sega Master System, Game Gear & SG-1000 Libretro Core"
rp_module_help="ROM Extensions: .bin .gg .sg .sms .rom .zip\n\nCopy Game Gear ROMs To: ${romdir}/gamegear\n\nCopy MasterSystem ROMs To: ${romdir}/mastersystem\n\nCopy SG-1000 ROMs To: ${romdir}/sg-1000\n\nOPTIONAL:\nCopy BIOS File: bios.sms To: ${biosdir}/mastersystem\nCopy BIOS File: bios.gg To: ${biosdir}/gamegear"
rp_module_licence="GPL3 https://raw.githubusercontent.com/drhelius/Gearsystem/master/LICENSE"
rp_module_repo="git https://github.com/drhelius/Gearsystem master"
rp_module_section="exp"

function sources_lr-gearsystem() {
    gitPullOrClone
}

function build_lr-gearsystem() {
    make -C platforms/libretro clean
    make -C platforms/libretro
    md_ret_require="${md_build}/platforms/libretro/gearsystem_libretro.so"
}

function install_lr-gearsystem() {
    md_ret_files=('platforms/libretro/gearsystem_libretro.so')
}

function configure_lr-gearsystem() {
    local systems=(
        'gamegear'
        'mastersystem'
        'sg-1000'
    )

    if [[ "${md_mode}" == "install" ]]; then
        for system in "${systems[@]}"; do
            mkRomDir "${system}"
            mkUserDir "${biosdir}/${system}"
            defaultRAConfig "${system}"
        done
    fi

    for system in "${systems[@]}"; do
        addEmulator 0 "${md_id}" "${system}" "${md_inst}/gearsystem_libretro.so"
        addSystem "${system}"
    done
}
