#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-snes9x2002"
rp_module_desc="Nintendo SNES 1.39 Libretro Core"
rp_module_help="ROM Extensions: .bin .smc .sfc .fig .swc .mgd .zip\n\nCopy your SNES roms to $romdir/snes"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/snes9x2002/master/src/copyright.h"
rp_module_repo="git https://github.com/libretro/snes9x2002 master"
rp_module_section="opt"
rp_module_flags="!all arm"

function sources_lr-snes9x2002() {
    gitPullOrClone
}

function build_lr-snes9x2002() {
    make clean
    CFLAGS="$CFLAGS -Wa,-mimplicit-it=thumb" make ARM_ASM=1
    md_ret_require="$md_build/snes9x2002_libretro.so"
}

function install_lr-snes9x2002() {
    md_ret_files=(
        'snes9x2002_libretro.so'
        'README.txt'
    )
}

function configure_lr-snes9x2002() {
    mkRomDir "snes"
    defaultRAConfig "snes"

    addEmulator 0 "$md_id" "snes" "$md_inst/snes9x2002_libretro.so"
    addSystem "snes"
}
