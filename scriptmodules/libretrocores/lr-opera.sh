#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-opera"
rp_module_desc="3DO Interactive Multiplayer Libretro Core"
rp_module_help="ROM Extension: .chd .cue .iso .zip\n\nCopy 3do ROMs To: ${romdir}/3do\n\nCopy BIOS File (panazf10.bin) To ${biosdir}/3do"
rp_module_licence="LGPL https://raw.githubusercontent.com/libretro/opera-libretro/master/libopera/opera_3do.c"
rp_module_repo="git https://github.com/libretro/opera-libretro master"
rp_module_section="exp"

function sources_lr-opera() {
    gitPullOrClone
}

function build_lr-opera() {
    make clean
    make
    md_ret_require="${md_build}/opera_libretro.so"
}

function install_lr-opera() {
    md_ret_files=('opera_libretro.so')
}

function configure_lr-opera() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "3do"

        mkUserDir "${biosdir}/3do"
    fi

    defaultRAConfig "3do" "system_directory" "${biosdir}/3do"

    addEmulator 1 "${md_id}" "3do" "${md_inst}/opera_libretro.so"

    addSystem "3do"
}
