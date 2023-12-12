#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-quasi88"
rp_module_desc="NEC PC-8801 Libretro Core"
rp_module_help="ROM Extensions: .d88 .m3u .u88\n\nCopy pc88 Games To: ${romdir}/pc88\n\nCopy BIOS Files:disk.rom, n88_0.rom, n88_1.rom, n88_2.rom, n88_3.rom, n88.rom, n88knj1.rom & n88n.rom To: ${biosdir}/pc88"
rp_module_licence="BSD https://raw.githubusercontent.com/libretro/quasi88-libretro/master/LICENSE"
rp_module_repo="git https://github.com/libretro/quasi88-libretro master"
rp_module_section="exp"

function sources_lr-quasi88() {
    gitPullOrClone
}

function build_lr-quasi88() {
    make clean
    make
    md_ret_require="${md_build}/quasi88_libretro.so"
}

function install_lr-quasi88() {
    md_ret_files=('quasi88_libretro.so')
}

function configure_lr-quasi88() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "pc88"
        mkUserDir "${biosdir}/pc88"
        defaultRAConfig "pc88"
    fi

    addEmulator 1 "${md_id}" "pc88" "${md_inst}/quasi88_libretro.so"

    addSystem "pc88"
}
