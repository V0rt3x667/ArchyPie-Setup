#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-snes9x"
rp_module_desc="Nintendo SNES Libretro Core"
rp_module_help="ROM Extensions: .bin .smc .sfc .fig .swc .mgd .zip\n\nCopy your SNES roms to $romdir/snes"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/snes9x/master/LICENSE"
rp_module_repo="git https://github.com/libretro/snes9x master"
rp_module_section="opt armv8=main x86=main"

function sources_lr-snes9x() {
    gitPullOrClone
}

function build_lr-snes9x() {
    local params=()
    isPlatform "arm" && params+=(platform="armv")

    cd libretro
    make "${params[@]}" clean
    # temporarily disable distcc due to segfaults with cross compiler and lto
    DISTCC_HOSTS="" make "${params[@]}"
    md_ret_require="$md_build/libretro/snes9x_libretro.so"
}

function install_lr-snes9x() {
    md_ret_files=(
        'libretro/snes9x_libretro.so'
        'docs'
    )
}

function configure_lr-snes9x() {
    mkRomDir "snes"
    defaultRAConfig "snes"

    local def=0
    ! isPlatform "armv7" && def=1
    addEmulator $def "$md_id" "snes" "$md_inst/snes9x_libretro.so"
    addSystem "snes"
}
