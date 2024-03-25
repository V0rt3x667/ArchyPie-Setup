#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-vbam"
rp_module_desc="Nintendo Game Boy, Game Boy Advance & Game Boy Color Libretro Core"
rp_module_help="ROM Extensions: .cgb .dmg .gb .gba .gbc .sgb .zip\n\nCopy Game Boy ROMs To: ${romdir}/gb\nCopy Game Boy Color ROMs To: ${romdir}/gbc\nCopy Game Boy Advance ROMs To: ${romdir}/gba\n\nOPTIONAL: Copy BIOS File: gb_bios.bin To: ${biosdir}/gb\n\nCopy BIOS File: gba_bios.bin To: ${biosdir}/gba\n\nCopy BIOS File: gbc_bios.bin To: ${biosdir}/gbc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/vbam-libretro/master/doc/gpl.txt"
rp_module_repo="git https://github.com/libretro/vbam-libretro master"
rp_module_section="opt"
rp_module_flags=""

function sources_lr-vbam() {
    gitPullOrClone
}

function build_lr-vbam() {
    make -C src/libretro clean
    make -C src/libretro
    md_ret_require="${md_build}/src/libretro/vbam_libretro.so"
}

function install_lr-vbam() {
    md_ret_files=('src/libretro/vbam_libretro.so')
}

function configure_lr-vbam() {
    local systems=(
        'gb'
        'gba'
        'gbc'
    )

    if [[ "${md_mode}" == "install" ]]; then
        for system in "${systems[@]}"; do
            mkRomDir "${system}"
            mkUserDir "${biosdir}/${system}"
            defaultRAConfig "${system}"
        done
    fi

    for system in "${systems[@]}"; do
        addEmulator 1 "${md_id}" "${system}" "${md_inst}/vbam_libretro.so"
        addSystem "${system}"
    done
}
