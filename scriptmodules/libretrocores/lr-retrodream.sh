#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-retrodream"
rp_module_desc="Sega Dreamcast Libretro Core"
rp_module_help="ROM Extensions: .cdi .gdi\n\nCopy Your Dreamcast ROMs to $romdir/dreamcast\n\nCopy the required BIOS files dc_boot.bin and dc_flash.bin to $biosdir"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/retrodream/master/LICENSE.txt"
rp_module_repo="git https://github.com/libretro/retrodream.git master"
rp_module_section="opt"

function sources_lr-retrodream() {
    gitPullOrClone
}

function build_lr-retrodream() {
    make clean
    make
    md_ret_require="$md_build/retrodream_libretro.so"
}

function install_lr-retrodream() {
    md_ret_files=('retrodream_libretro.so')
}

function configure_lr-retrodream() {
    mkRomDir "dreamcast"
    mkUserDir "$biosdir/dc"

    ensureSystemretroconfig "dreamcast"

    addEmulator 0 "$md_id" "dreamcast" "$md_inst/retrodream_libretro.so"
    addSystem "dreamcast"
}
