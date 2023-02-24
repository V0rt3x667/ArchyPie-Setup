#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-mame"
rp_module_desc="MAME (Latest Version) Libretro Core"
rp_module_help="ROM Extension: .zip\n\nCopy MAME ROMs To: ${romdir}/mame-libretro\nOr\n${romdir}/arcade"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/mame/master/COPYING"
rp_module_repo="git https://github.com/libretro/mame master"
rp_module_section="exp"
rp_module_flags=""

function _get_params_lr-mame() {
    local params=(CONFIG=libretro NO_USE_MIDI=1 NOWERROR=1 OS=linux OSD=retro PYTHON_EXECUTABLE=python RETRO=1 TARGET=mame TARGETOS=linux)
    isPlatform "64bit" && params+=('PTR64=1')
    echo "${params[@]}"
}

function depends_lr-mame() {
    local depends=('ffmpeg')
    isPlatform "gles" && depends+=('libglvnd')
    isPlatform "gl" && depends+=('glu')
    getDepends "${depends[@]}"
}

function sources_lr-mame() {
    gitPullOrClone
}

function build_lr-mame() {
    # More Memory Is Required For 64bit Platforms
    if isPlatform "64bit"; then
        rpSwap on 8192
    else
        rpSwap on 4096
    fi

    local params=($(_get_params_lr-mame) SUBTARGET=arcade)
    make clean
    make "${params[@]}"
    rpSwap off
    md_ret_require="${md_build}/mamearcade_libretro.so"
}

function install_lr-mame() {
    md_ret_files=('mamearcade_libretro.so')
}

function configure_lr-mame() {
    local system
    for system in arcade mame-libretro; do
        mkRomDir "${system}"
        defaultRAConfig "${system}"
        addEmulator 0 "${md_id}" "${system}" "${md_inst}/mamearcade_libretro.so"
        addSystem "${system}"
    done
}
