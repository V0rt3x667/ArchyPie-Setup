#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-mgba"
rp_module_desc="Nintendo Game Boy, Game Boy Advance & Game Boy Color Libretro Core"
rp_module_help="ROM Extensions: .gb .gba .gbc .zip\n\nCopy Game Boy ROMs To: ${romdir}/gb\nCopy Game Boy Color ROMs To: ${romdir}/gbc\nCopy Game Boy Advance ROMs To: ${romdir}/gba\n\nOPTIONAL:\nCopy BIOS File (gb_bios.bin) To: ${biosdir}/gb\nCopy BIOS File (gba_bios.bin) To: ${biosdir}/gba\nCopy BIOS File (gbc_bios.bin) To: ${biosdir}/gbc"
rp_module_licence="MPL2 https://raw.githubusercontent.com/libretro/mgba/master/LICENSE"
rp_module_repo="git https://github.com/libretro/mgba master"
rp_module_section="main"
rp_module_flags=""

function sources_lr-mgba() {
    gitPullOrClone
}

function build_lr-mgba() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro
    md_ret_require="${md_build}/mgba_libretro.so"
}

function install_lr-mgba() {
    md_ret_files=(
        'LICENSE'
        'mgba_libretro.so'
    )
}

function configure_lr-mgba() {
    local system
    local def

    if [[ "${md_mode}" == "install" ]]; then
        for system in 'gb' 'gba' 'gbc'; do
            mkRomDir "${system}"
            mkUserDir "${biosdir}/${system}"
        done
    fi

    for system in 'gb' 'gba' 'gbc'; do
        def=0
        [[ "${system}" == "gba" ]] && def=1
        defaultRAConfig "${system}" "system_directory" "${biosdir}/${system}"
        addEmulator "${def}" "${md_id}" "${system}" "${md_inst}/mgba_libretro.so"
        addSystem "${system}"
    done
}
