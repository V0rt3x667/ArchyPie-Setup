#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE.md file at the top-level directory of this distribution.

rp_module_id="lr-mesen-s"
rp_module_desc="Nintendo SNES (Super Famicom), Game Boy, Game Boy Color & Super Game Boy Libretro Core"
rp_module_help="ROM Extensions: .bs .fig .gb .gbc .sfc .smc .swc\n\nCopy Game Boy ROMs To: ${romdir}/gb\n\nCopy Game Boy Color ROMs To: ${romdir}/gbc\n\nCopy SNES ROMs To: ${romdir}/snes"
rp_module_licence="GPL3 https://raw.githubusercontent.com/SourMesen/Mesen-S/master/LICENSE"
rp_module_repo="git https://github.com/SourMesen/Mesen-S master"
rp_module_section="opt"

function sources_lr-mesen-s() {
    gitPullOrClone
}

function build_lr-mesen-s() {
    make -C Libretro clean
    make -C Libretro
    md_ret_require="${md_build}/Libretro/mesens_libretro.so"
}

function install_lr-mesen-s() {
    md_ret_files=('Libretro/mesens_libretro.so')
}

function configure_lr-mesen-s() {
    local system
    for system in "gb" "gbc" "snes"; do
        mkRomDir "${system}"
        defaultRAConfig "${system}"
        addEmulator 0 "${md_id}" "${system}" "${md_inst}/mesens_libretro.so"
        addSystem "${system}"
    done
}
