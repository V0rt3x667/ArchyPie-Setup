#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-bsnes-mercury"
rp_module_desc="Nintendo SNES Libretro Core"
rp_module_help="ROM Extensions: .bin .smc .sfc .fig .swc .mgd .zip\n\nCopy Your SNES ROMs to $romdir/snes"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/bsnes-mercury/master/LICENSE"
rp_module_repo="git https://github.com/libretro/bsnes-mercury master"
rp_module_section="opt"

function sources_lr-bsnes-mercury() {
    gitPullOrClone
}

function build_lr-bsnes-mercury() {
    local profile
    #surpress undefined reference errors when building the balanced core
    sed -e "s|--no-undefined -Wl,||g" -i ./Makefile
    for profile in 'accuracy' 'balanced' 'performance'; do
        make clean
        make PROFILE="$profile"
    done
    md_ret_require=(
        "$md_build/bsnes_mercury_accuracy_libretro.so"
        "$md_build/bsnes_mercury_balanced_libretro.so"
        "$md_build/bsnes_mercury_performance_libretro.so"
    )
}

function install_lr-bsnes-mercury() {
    md_ret_files=(
        'bsnes_mercury_accuracy_libretro.so'
        'bsnes_mercury_balanced_libretro.so'
        'bsnes_mercury_performance_libretro.so'
    )
}

function configure_lr-bsnes-mercury() {
    mkRomDir "snes"
    defaultRAConfig "snes"

    addEmulator 0 "$md_id" "snes" "$md_inst/bsnes_mercury_accuracy_libretro.so"
    addEmulator 0 "$md_id" "snes" "$md_inst/bsnes_mercury_balanced_libretro.so"
    addEmulator 0 "$md_id" "snes" "$md_inst/bsnes_mercury_performance_libretro.so"

    addSystem "snes"
}
