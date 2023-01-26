#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-snes9x2005"
rp_module_desc="Nintendo SNES 1.43 Libretro Core"
rp_module_help="ROM Extensions: .bin .smc .sfc .fig .swc .mgd .zip\n\nCopy your SNES roms to $romdir/snes"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/snes9x2005/master/copyright"
rp_module_repo="git https://github.com/libretro/snes9x2005 master"
rp_module_section="opt arm=main"

function sources_lr-snes9x2005() {
    gitPullOrClone
}

function build_lr-snes9x2005() {
    make clean
    make
    md_ret_require="$md_build/snes9x2005_libretro.so"
}

function install_lr-snes9x2005() {
    md_ret_files=(
        'snes9x2005_libretro.so'
    )
}

function configure_lr-snes9x2005() {
    mkRomDir "snes"
    defaultRAConfig "snes"

    addEmulator 0 "$md_id" "snes" "$md_inst/snes9x2005_libretro.so"
    addSystem "snes"
}
