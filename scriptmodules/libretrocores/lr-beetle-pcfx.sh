#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-beetle-pcfx"
rp_module_desc="NEC PC-FX Libretro Core"
rp_module_help="ROM Extensions: .img .iso .ccd .cue\n\nCopy the required BIOS file pcfx.rom to $biosdir"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-pcfx-libretro/master/COPYING"
rp_module_repo="git https://github.com/libretro/beetle-pcfx-libretro master"
rp_module_section="exp"

function sources_lr-beetle-pcfx() {
    gitPullOrClone
}

function build_lr-beetle-pcfx() {
    make clean
    make
    md_ret_require="$md_build/mednafen_pcfx_libretro.so"
}

function install_lr-beetle-pcfx() {
    md_ret_files=(
        'mednafen_pcfx_libretro.so'
    )
}

function configure_lr-beetle-pcfx() {
    mkRomDir "pcfx"
    defaultRAConfig "pcfx"

    addEmulator 1 "$md_id" "pcfx" "$md_inst/mednafen_pcfx_libretro.so"
    addSystem "pcfx"
}
