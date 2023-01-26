#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-vba-next"
rp_module_desc=" Game Boy Advance Libretro Core"
rp_module_help="ROM Extensions: .gba .zip\n\nCopy your Game Boy Advance roms to $romdir/gba\n\nCopy the required BIOS file gba_bios.bin to $biosdir"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/vba-next/master/LICENSE"
rp_module_repo="git https://github.com/libretro/vba-next master"
rp_module_section="main"
rp_module_flags=""

function sources_lr-vba-next() {
    gitPullOrClone
}

function build_lr-vba-next() {
    make -f Makefile.libretro clean
    if isPlatform "neon"; then
        make -f Makefile.libretro platform=armvhardfloatunix TILED_RENDERING=1 HAVE_NEON=1
    else
        make -f Makefile.libretro
    fi
    md_ret_require="$md_build/vba_next_libretro.so"
}

function install_lr-vba-next() {
    md_ret_files=(
        'vba_next_libretro.so'
    )
}

function configure_lr-vba-next() {
    mkRomDir "gba"
    defaultRAConfig "gba"

    addEmulator 0 "$md_id" "gba" "$md_inst/vba_next_libretro.so"
    addSystem "gba"
}
