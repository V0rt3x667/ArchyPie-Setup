#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-beetle-psx"
rp_module_desc="Sony PlayStation Libretro Core"
rp_module_help="ROM Extensions: .ccd .chd .cue .exe .m3u .pbp .toc\n\nCopy PlayStation ROMs To: ${romdir}/psx\n\nCopy BIOS Files:\n\nscph5500.bin\nscph5501.bin\nscph5502.bin\n\nTo: ${biosdir}/psx"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-psx-libretro/master/COPYING"
rp_module_repo="git https://github.com/libretro/beetle-psx-libretro master"
rp_module_section="opt"
rp_module_flags=""

function depends_lr-beetle-psx() {
    local depends=(
        'libglvnd'
        'mesa'
        'vulkan-icd-loader'
    )
    getDepends "${depends[@]}"
}

function sources_lr-beetle-psx() {
    gitPullOrClone
}

function build_lr-beetle-psx() {
    make clean
    make HAVE_HW=1
    md_ret_require=('mednafen_psx_hw_libretro.so')
}

function install_lr-beetle-psx() {
    md_ret_files=('mednafen_psx_hw_libretro.so')
}

function configure_lr-beetle-psx() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "psx"

        mkUserDir "${biosdir}/psx"
    fi

    defaultRAConfig "psx" "system_directory" "${biosdir}/psx"

    addEmulator 0 "${md_id}" "psx" "${md_inst}/mednafen_psx_hw_libretro.so"

    addSystem "psx"
}
