#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-o2em"
rp_module_desc="Magnavox Odyssey 2 (Philips VideoPac+) Libretro Core"
rp_module_help="ROM Extensions: .bin .zip\n\nCopy Odyssey 2 (Videopac+) ROMs To: ${romdir}/videopac\n\nCopy BIOS File: o2rom.bin To: ${biosdir}/videopac"
rp_module_licence="OTHER https://raw.githubusercontent.com/libretro/libretro-o2em/master/COPYING"
rp_module_repo="git https://github.com/libretro/libretro-o2em master"
rp_module_section="opt"

function sources_lr-o2em() {
    gitPullOrClone
}

function build_lr-o2em() {
    make clean
    make
    md_ret_require="${md_build}/o2em_libretro.so"
}

function install_lr-o2em() {
    md_ret_files=(
        'COPYING'
        'o2em_libretro.so'
    )
}

function configure_lr-o2em() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "videopac"
        mkUserDir "${biosdir}/videopac"
        defaultRAConfig "videopac"
    fi

    addEmulator 1 "${md_id}" "videopac" "${md_inst}/o2em_libretro.so"

    addSystem "videopac"
}
