#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-beetle-supergrafx"
rp_module_desc="NEC PC Engine SuperGrafx Fast Libretro Core"
rp_module_help="ROM Extensions: .ccd .chd .cue .pce .sgx\n\nCopy PC Engine SuperGrafx ROMs To Either: ${romdir}/pcengine\n${romdir}/supergrafx\n\nCopy BIOS File: syscard3.pce To: ${biosdir}/pcengine"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-supergrafx-libretro/master/COPYING"
rp_module_repo="git https://github.com/libretro/beetle-supergrafx-libretro master"
rp_module_section="main"

function sources_lr-beetle-supergrafx() {
    gitPullOrClone
}

function build_lr-beetle-supergrafx() {
    make clean
    make
    md_ret_require="${md_build}/mednafen_supergrafx_libretro.so"
}

function install_lr-beetle-supergrafx() {
    md_ret_files=('mednafen_supergrafx_libretro.so')
}

function configure_lr-beetle-supergrafx() {
    local systems=(
        'pce-cd'
        'pcengine'
        'supergrafx'
    )

    if [[ "${md_mode}" == "install" ]]; then
        for system in "${systems[@]}"; do
            mkRomDir "${system}"
            defaultRAConfig "${system}" "system_directory" "${biosdir}/pcengine"
        done

        mkUserDir "${biosdir}/pcengine"
    fi

    for system in "${systems[@]}"; do
        addEmulator 0 "${md_id}" "${system}" "${md_inst}/mednafen_supergrafx_libretro.so"
        addSystem "${system}"
    done
}
