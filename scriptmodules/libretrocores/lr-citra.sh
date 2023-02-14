#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-citra"
rp_module_desc="Nintendo 3DS Libretro Core"
rp_module_help="ROM Extensions: .3ds .3dsx .app .axf .cci .cxi .elf\n\nCopy 3DS ROMs To: ${romdir}/3ds"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/citra/master/license.txt"
rp_module_repo="git https://github.com/libretro/citra master"
rp_module_section="opt"
rp_module_flags="!all 64bit"

function depends_lr-citra() {
    local depends=(
        'ffmpeg'
        'fmt'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_lr-citra() {
    gitPullOrClone

    # Fix Missing Include
    sed "/#include <vector>/a #include <limits>/" -i "${md_build}/src/common/ring_buffer.h"
}

function build_lr-citra() {
    make HAVE_FFMPEG_STATIC=0 clean
    make HAVE_FFMPEG_STATIC=0
    md_ret_require="${md_build}/citra_libretro.so"
}

function install_lr-citra() {
    md_ret_files=('citra_libretro.so')
}

function configure_lr-citra() {
    mkRomDir "3ds"

    defaultRAConfig "3ds"

    addEmulator 0 "${md_id}" "3ds" "${md_inst}/citra_libretro.so"

    addSystem "3ds"
}
