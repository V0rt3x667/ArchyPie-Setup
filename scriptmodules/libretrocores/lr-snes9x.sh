#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-snes9x"
rp_module_desc="Nintendo SNES Libretro Core"
rp_module_help="ROM Extensions: .bs .fig .sfc .smc .st .swc .zip\n\nCopy SNES ROMs To: ${romdir}/snes"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/snes9x/master/LICENSE"
rp_module_repo="git https://github.com/libretro/snes9x master"
rp_module_section="opt armv8=main x86=main"

function sources_lr-snes9x() {
    gitPullOrClone
}

function build_lr-snes9x() {
    local params=()
    isPlatform "arm" && params+=(platform="armv")

    make -C libretro "${params[@]}" clean
    make -C libretro "${params[@]}"
    md_ret_require="${md_build}/libretro/snes9x_libretro.so"
}

function install_lr-snes9x() {
    md_ret_files=('libretro/snes9x_libretro.so')
}

function configure_lr-snes9x() {
    mkRomDir "snes"

    defaultRAConfig "snes"

    local def=0
    ! isPlatform "armv7" && def=1
    addEmulator ${def} "${md_id}" "snes" "${md_inst}/snes9x_libretro.so"

    addSystem "snes"
}
