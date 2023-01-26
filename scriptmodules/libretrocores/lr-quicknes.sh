#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-quicknes"
rp_module_desc="Nintendo Entertainment System Libretro Core"
rp_module_help="ROM Extensions: .nes .zip\n\nCopy your NES roms to $romdir/nes"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/QuickNES_Core/master/LICENSE"
rp_module_repo="git https://github.com/libretro/QuickNES_Core master"
rp_module_section="opt"

function sources_lr-quicknes() {
    gitPullOrClone
}

function build_lr-quicknes() {
    make clean
    make
    md_ret_require="$md_build/quicknes_libretro.so"
}

function install_lr-quicknes() {
    md_ret_files=(
        'quicknes_libretro.so'
    )
}

function configure_lr-quicknes() {
    mkRomDir "nes"
    defaultRAConfig "nes"

    addEmulator 0 "$md_id" "nes" "$md_inst/quicknes_libretro.so"
    addSystem "nes"
}
