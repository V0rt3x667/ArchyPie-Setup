#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-pokemini"
rp_module_desc="Pokémon-Mini Libretro Core"
rp_module_help="ROM Extensions: .min .zip\n\nCopy your Pokemon Mini roms to $romdir/pokemini"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/PokeMini/master/LICENSE"
rp_module_repo="git https://github.com/libretro/pokemini master"
rp_module_section="exp"

function sources_lr-pokemini() {
    gitPullOrClone
}

function build_lr-pokemini() {
    make clean
    make
    md_ret_require="$md_build/pokemini_libretro.so"
}

function install_lr-pokemini() {
    md_ret_files=(
        'pokemini_libretro.so'
    )
}

function configure_lr-pokemini() {
    mkRomDir "pokemini"
    defaultRAConfig "pokemini"

    addEmulator 1 "$md_id" "pokemini" "$md_inst/pokemini_libretro.so"
    addSystem "pokemini"
}
