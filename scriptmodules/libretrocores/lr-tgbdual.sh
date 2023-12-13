#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-tgbdual"
rp_module_desc="Nintendo Gameboy & Gameboy Color Libretro Core"
rp_module_help="ROM Extensions: .cgb .dmg .gb .gbc .sgb .zip\n\nCopy GameBoy ROMs To: ${romdir}/gb\n\nCopy GameBoy Color ROMs To: ${romdir}/gbc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/tgbdual-libretro/master/docs/COPYING-2.0.txt"
rp_module_repo="git https://github.com/libretro/tgbdual-libretro master"
rp_module_section="opt"

function sources_lr-tgbdual() {
    gitPullOrClone
}

function build_lr-tgbdual() {
    make clean
    make
    md_ret_require="${md_build}/tgbdual_libretro.so"
}

function install_lr-tgbdual() {
    md_ret_files=('tgbdual_libretro.so')
}

function configure_lr-tgbdual() {
    local systems=(
        'gb'
        'gbc'
    )

    if [[ "${md_mode}" == "install" ]]; then
        for system in "${systems[@]}"; do
            mkRomDir "${system}"
            defaultRAConfig "${system}"
        done

        # Enable Dual Link By Default
        setRetroArchCoreOption "tgbdual_gblink_enable" "enabled"
    fi

    for system in "${systems[@]}"; do
        addEmulator 0 "${md_id}" "${system}" "${md_inst}/tgbdual_libretro.so"
        addSystem "${system}"
    done
}
