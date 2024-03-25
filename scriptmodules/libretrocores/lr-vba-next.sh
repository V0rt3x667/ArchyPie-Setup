#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-vba-next"
rp_module_desc="Nintendo Game Boy Advance Libretro Core"
rp_module_help="ROM Extensions: .gba .zip\n\nCopy Game Boy Advance ROMs To: ${romdir}/gba\n\nOPTIONAL: Copy BIOS File: gba_bios.bin To: ${biosdir}/gba"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/vba-next/master/LICENSE"
rp_module_repo="git https://github.com/libretro/vba-next master"
rp_module_section="opt"
rp_module_flags=""

function sources_lr-vba-next() {
    gitPullOrClone
}

function build_lr-vba-next() {
    make -f Makefile.libretro clean
    if isPlatform "neon"; then
        make -f Makefile.libretro platform=armvhardfloatunix TILED_RENDERING=1 HAVE_NEON=1
    else
        make -f Makefile.libretro
    fi
    md_ret_require="${md_build}/vba_next_libretro.so"
}

function install_lr-vba-next() {
    md_ret_files=('vba_next_libretro.so')
}

function configure_lr-vba-next() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "gba"
        mkUserDir "${biosdir}/gba"
        defaultRAConfig "gba"
    fi

    addEmulator 0 "${md_id}" "gba" "${md_inst}/vba_next_libretro.so"

    addSystem "gba"
}
