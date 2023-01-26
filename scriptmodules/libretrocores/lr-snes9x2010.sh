#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-snes9x2010"
rp_module_desc="Nintendo SNES 1.52 Libretro Core"
rp_module_help="ROM Extensions: .bin .smc .sfc .fig .swc .mgd .zip\n\nCopy your SNES roms to $romdir/snes"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/snes9x2010/master/docs/snes9x-license.txt"
rp_module_repo="git https://github.com/libretro/snes9x2010 master"
rp_module_section="opt arm=main"

function sources_lr-snes9x2010() {
    gitPullOrClone
}

function build_lr-snes9x2010() {
    make -f Makefile.libretro clean
    local platform=""
    isPlatform "arm" && platform+="armv"
    isPlatform "neon" && platform+="neon"
    if [[ -n "$platform" ]]; then
        make -f Makefile.libretro platform="$platform"
    else
        make -f Makefile.libretro
    fi
    md_ret_require="$md_build/snes9x2010_libretro.so"
}

function install_lr-snes9x2010() {
    md_ret_files=(
        'snes9x2010_libretro.so'
        'docs'
    )
}

function configure_lr-snes9x2010() {
    mkRomDir "snes"
    defaultRAConfig "snes"

    local def=0
    isPlatform "armv7" && def=1
    addEmulator $def "$md_id" "snes" "$md_inst/snes9x2010_libretro.so"
    addSystem "snes"
}
