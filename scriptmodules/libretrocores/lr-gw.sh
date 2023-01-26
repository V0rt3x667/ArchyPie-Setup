#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-gw"
rp_module_desc="Nintendo Game & Watch Libretro Core"
rp_module_help="ROM Extension: .mgw\n\nCopy your Game and Watch games to $romdir/gameandwatch"
rp_module_licence="ZLIB https://raw.githubusercontent.com/libretro/gw-libretro/master/LICENSE"
rp_module_repo="git https://github.com/libretro/gw-libretro master"
rp_module_section="opt"

function sources_lr-gw() {
    gitPullOrClone
}

function build_lr-gw() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro
    md_ret_require="$md_build/gw_libretro.so"
}

function install_lr-gw() {
    md_ret_files=(
        'gw_libretro.so'
        'LICENSE'
        'README.md'
    )
}

function configure_lr-gw() {
    mkRomDir "gameandwatch"
    defaultRAConfig "gameandwatch"

    addEmulator 1 "$md_id" "gameandwatch" "$md_inst/gw_libretro.so"
    addSystem "gameandwatch"
}
