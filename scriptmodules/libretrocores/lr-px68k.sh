#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-px68k"
rp_module_desc="Sharp X68000 Libretro Core"
rp_module_help="You need to copy a X68000 bios file (iplrom30.dat, iplromco.dat, iplrom.dat, or iplromxv.dat), and the font file (cgrom.dat or cgrom.tmp) to $biosdir/keropi. Use F12 to access the in emulator menu."
rp_module_repo="git https://github.com/libretro/px68k-libretro master"
rp_module_section="exp"
rp_module_flags=""

function sources_lr-px68k() {
    gitPullOrClone
}

function build_lr-px68k() {
    make clean
    make
    md_ret_require="$md_build/px68k_libretro.so"
}

function install_lr-px68k() {
    md_ret_files=(
        'px68k_libretro.so'
        'README.MD'
        'readme.txt'
    )
}

function configure_lr-px68k() {
    mkRomDir "x68000"
    defaultRAConfig "x68000"

    mkUserDir "$biosdir/keropi"

    addEmulator 1 "$md_id" "x68000" "$md_inst/px68k_libretro.so"
    addSystem "x68000"
}
