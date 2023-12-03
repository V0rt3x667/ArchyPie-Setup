#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-beetle-psx"
rp_module_desc="Sony PlayStation Libretro Core"
rp_module_help="ROM Extensions: .ccd .chd .cue .exe .m3u .pbp .toc\n\nCopy PlayStation ROMs To: ${romdir}/psx\n\nCopy BIOS Files:scph5500.bin, scph5501.bin & scph5502.bin To: ${biosdir}/psx"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-psx-libretro/master/COPYING"
rp_module_repo="git https://github.com/libretro/beetle-psx-libretro master"
rp_module_section="opt x86=main"
rp_module_flags="!arm"

function depends_lr-beetle-psx-hw() {
    local depends=(
        'mesa'
        'vulkan-icd-loader'
    )
    getDepends "${depends[@]}"
}

function sources_lr-beetle-psx() {
    gitPullOrClone
}

function build_lr-beetle-psx() {
    # Hardware Acceleration Enabled By Default
    make clean
    make HAVE_HW=1

    # Software Renderer Enabled By Default: Greater Accuracy Higher CPU Cost
    make clean
    make
    md_ret_require=(
        'mednafen_psx_hw_libretro.so'
        'mednafen_psx_libretro.so'
    )
}

function install_lr-beetle-psx() {
    md_ret_files=(
        'mednafen_psx_hw_libretro.so'
        'mednafen_psx_libretro.so'
    )
}

function configure_lr-beetle-psx() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "psx"
        mkUserDir "${biosdir}/psx"
        defaultRAConfig "psx" "system_directory" "${biosdir}/psx"
    fi

    addEmulator 1 "${md_id}-hw" "psx" "${md_inst}/mednafen_psx_hw_libretro.so"
    addEmulator 0 "${md_id}-sw" "psx" "${md_inst}/mednafen_psx_libretro.so"

    addSystem "psx"
}
