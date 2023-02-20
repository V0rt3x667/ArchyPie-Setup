#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-freeintv"
rp_module_desc="Mattel Intellivision Libretro Core"
rp_module_help="ROM Extensions: .bin .int .rom\n\nCopy Intellivision ROMs To: ${romdir}/intellivision\n\nCopy BIOS Files (exec.bin & grom.bin) To: ${biosdir}/intellivision"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/FreeIntv/master/LICENSE"
rp_module_repo="git https://github.com/libretro/FreeIntv master"
rp_module_section="opt"

function sources_lr-freeintv() {
    gitPullOrClone
}

function build_lr-freeintv() {
    make clean
    make
    md_ret_require="${md_build}/freeintv_libretro.so"
}

function install_lr-freeintv() {
    md_ret_files=('freeintv_libretro.so')
}

function configure_lr-freeintv() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "intellivision"

        mkUserDir "${biosdir}/intellivision"
    fi

    defaultRAConfig "intellivision" "system_directory" "${biosdir}/intellivision"

    addEmulator 1 "${md_id}" "intellivision" "${md_inst}/freeintv_libretro.so"

    addSystem "intellivision"
}
