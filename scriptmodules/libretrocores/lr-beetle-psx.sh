#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-beetle-psx"
rp_module_desc="Sony PlayStation Libretro Core"
rp_module_help="ROM Extensions: .bin .cue .cbn .img .iso .m3u .mdf .pbp .toc .z .znx\n\nCopy your PlayStation roms to $romdir/psx\n\nCopy the required BIOS files\n\nscph5500.bin and\nscph5501.bin and\nscph5502.bin to\n\n$biosdir"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-psx-libretro/master/COPYING"
rp_module_repo="git https://github.com/libretro/beetle-psx-libretro master"
rp_module_section="opt x86=main"
rp_module_flags="!arm"

function depends_lr-beetle-psx() {
    local depends=('vulkan-icd-loader' 'libglvnd')
    getDepends "${depends[@]}"
}

function sources_lr-beetle-psx() {
    gitPullOrClone
}

function build_lr-beetle-psx() {
    make clean
    make HAVE_HW=1
    md_ret_require=(
        'mednafen_psx_hw_libretro.so'
    )
}

function install_lr-beetle-psx() {
    md_ret_files=(
        'mednafen_psx_hw_libretro.so'
    )
}

function configure_lr-beetle-psx() {
    mkRomDir "psx"
    defaultRAConfig "psx"

    addEmulator 0 "$md_id" "psx" "$md_inst/mednafen_psx_hw_libretro.so"
    addSystem "psx"
}
