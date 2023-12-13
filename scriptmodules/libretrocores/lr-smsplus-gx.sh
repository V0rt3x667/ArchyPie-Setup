#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-smsplus-gx"
rp_module_desc="Sega Master System, Game Gear & Coleco ColecoVision Libretro Core"
rp_module_help="ROM Extensions: .bin .col .gg .rom .sg .sms .zip\nCopy Game Gear ROMs To: ${romdir}/gamegear\n\nCopy MasterSystem ROMs To: ${romdir}/mastersystem\n\nCopy ColecoVision ROMs To: ${romdir}/coleco\n\nOPTIONAL: Copy BIOS File: bios.sms To: ${biosdir}/mastersystem\nCopy BIOS File: BIOS.col To: ${biosdir}/coleco"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/smsplus-gx/master/docs/license"
rp_module_repo="git https://github.com/libretro/smsplus-gx master"
rp_module_section="exp"

function sources_lr-smsplus-gx() {
    gitPullOrClone
}

function build_lr-smsplus-gx() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro
    md_ret_require="${md_build}/smsplus_libretro.so"
}

function install_lr-smsplus-gx() {
    md_ret_files=('smsplus_libretro.so')
}

function configure_lr-smsplus-gx() {
    local systems=(
        'coleco'
        'gamegear'
        'mastersystem'
    )

    if [[ "${md_mode}" == "install" ]]; then
        for system in "${systems[@]}"; do
            mkRomDir "${system}"
            mkUserDir "${biosdir}/${system}"
            defaultRAConfig "${system}"
        done
    fi

    for system in "${systems[@]}"; do
        addEmulator 0 "${md_id}" "${system}" "${md_inst}/smsplus_libretro.so"
        addSystem "${system}"
    done
}
