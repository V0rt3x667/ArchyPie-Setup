#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-freeintv"
rp_module_desc="Mattel Intellivision Libretro Core"
rp_module_help="ROM Extensions: .int .bin\n\nCopy your Intellivision roms to $romdir/intellivision\n\nCopy the required BIOS files exec.bin and grom.bin to $biosdir"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/FreeIntv/master/LICENSE"
rp_module_repo="git https://github.com/libretro/FreeIntv master"
rp_module_section="opt"

function sources_lr-freeintv() {
    gitPullOrClone
}

function build_lr-freeintv() {
    make clean
    make
    md_ret_require="$md_build/freeintv_libretro.so"
}

function install_lr-freeintv() {
    md_ret_files=(
        'freeintv_libretro.so'
        'LICENSE'
        'README.md'
    )
}

function configure_lr-freeintv() {
    mkRomDir "intellivision"
    defaultRAConfig "intellivision"

    addEmulator 1 "$md_id" "intellivision" "$md_inst/freeintv_libretro.so"
    addSystem "intellivision"
}
