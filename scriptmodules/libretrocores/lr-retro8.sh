#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-retro8"
rp_module_desc="PICO-8 Fantasy Console Libretro Core"
rp_module_help="ROM Extensions: .p8 .p8.png .zip\n\nCopy your roms to $romdir/pico8"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/retro8/master/LICENSE"
rp_module_repo="git https://github.com/libretro/retro8 master"
rp_module_section="exp"

function sources_lr-retro8() {
    gitPullOrClone
}

function build_lr-retro8() {
    make clean
    make
    md_ret_require="$md_build/retro8_libretro.so"
}

function install_lr-retro8() {
    md_ret_files=(
        'retro8_libretro.so'
        'README.md'
        'LICENSE'
    )
}

function configure_lr-retro8() {
    mkRomDir "pico8"

    addEmulator 1 "$md_id" "pico8" "$md_inst/retro8_libretro.so"
    addSystem "pico8"

    [[ "$md_mode" == "remove" ]] && return

    # disable retroarch built-in imageviewer so we can run .p8.png files
    defaultRAConfig "pico8" "builtin_imageviewer_enable" "false"
}
