#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-o2em"
rp_module_desc="Magnavox Odyssey 2 (Philips VideoPac) Libretro Core"
rp_module_help="ROM Extensions: .bin .zip\n\nCopy your Odyssey 2 / Videopac roms to $romdir/videopac\n\nCopy the required BIOS file o2rom.bin to $biosdir"
rp_module_licence="OTHER"
rp_module_repo="git https://github.com/libretro/libretro-o2em master"
rp_module_section="opt"

function sources_lr-o2em() {
    gitPullOrClone
}

function build_lr-o2em() {
    make clean
    make
    md_ret_require="$md_build/o2em_libretro.so"
}

function install_lr-o2em() {
    md_ret_files=(
        'o2em_libretro.so'
        'README.md'
    )
}

function configure_lr-o2em() {
    mkRomDir "videopac"
    ensureSystemretroconfig "videopac"

    addEmulator 1 "$md_id" "videopac" "$md_inst/o2em_libretro.so"
    addSystem "videopac"
}
