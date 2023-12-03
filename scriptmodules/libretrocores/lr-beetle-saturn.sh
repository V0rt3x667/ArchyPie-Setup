#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-beetle-saturn"
rp_module_desc="Sega Saturn Libretro Core"
rp_module_help="ROM Extensions: .ccd .chd .cue .m3u .toc\n\nCopy Saturn ROMs To: ${romdir}/saturn\n\nCopy BIOS Files: sega_101.bin & mpr-17933.bin To: ${biosdir}/saturn"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-saturn-libretro/master/COPYING"
rp_module_repo="git https://github.com/libretro/beetle-saturn-libretro master"
rp_module_section="exp"
rp_module_flags=""

function sources_lr-beetle-saturn() {
    gitPullOrClone
}

function build_lr-beetle-saturn() {
    make clean
    make
    md_ret_require="${md_build}/mednafen_saturn_libretro.so"
}

function install_lr-beetle-saturn() {
    md_ret_files=('mednafen_saturn_libretro.so')
}

function configure_lr-beetle-saturn() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "saturn"
        mkUserDir "${biosdir}/saturn"
        defaultRAConfig "saturn" "system_directory" "${biosdir}/saturn"
    fi

    addEmulator 1 "${md_id}" "saturn" "${md_inst}/mednafen_saturn_libretro.so"

    addSystem "saturn"
}
