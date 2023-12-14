#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-yabause"
rp_module_desc="Sega Saturn Libretro Core"
rp_module_help="ROM Extensions: .bin .ccd .chd .cue .iso .m3u .mds .zip\n\nCopy Sega Saturn ROMs To: ${romdir}/saturn\n\nCopy BIOS File: saturn_bios.bin To: ${biosdir}/saturn"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/yabause/master/yabause/COPYING"
rp_module_repo="git https://github.com/libretro/yabause master"
rp_module_section="exp"
rp_module_flags=""

function sources_lr-yabause() {
    gitPullOrClone
}

function build_lr-yabause() {
    local params=()
    isPlatform "neon" && params+=('platform=armvneonhardfloat')
    ! isPlatform "x86" && params+=('HAVE_SSE=0')

    make -C yabause/src/libretro "${params[@]}" clean
    make -C yabause/src/libretro "${params[@]}"
    md_ret_require="${md_build}/yabause/src/libretro/yabause_libretro.so"
}

function install_lr-yabause() {
    md_ret_files=('yabause/src/libretro/yabause_libretro.so')
}

function configure_lr-yabause() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "saturn"
        mkUserDir "${biosdir}/saturn"
        defaultRAConfig "saturn" 
    fi

    addEmulator 1 "${md_id}" "saturn" "${md_inst}/yabause_libretro.so"

    addSystem "saturn"
}
