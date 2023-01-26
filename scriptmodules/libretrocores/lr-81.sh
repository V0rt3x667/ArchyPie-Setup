#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-81"
rp_module_desc="Sinclair ZX81 Libretro Core"
rp_module_help="ROM Extensions: .p .tzx .t81\n\nCopy your ZX81 roms to $romdir/zx81"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/81-libretro/master/LICENSE"
rp_module_repo="git https://github.com/libretro/81-libretro master"
rp_module_section="exp"

function sources_lr-81() {
    gitPullOrClone
}

function build_lr-81() {
    make clean
    make -f Makefile.libretro
    md_ret_require="$md_build/81_libretro.so"
}

function install_lr-81() {
    md_ret_files=(
        'README.md'
        '81_libretro.so'
    )
}

function configure_lr-81() {
    mkRomDir "zx81"
    defaultRAConfig "zx81"

    addEmulator 1 "$md_id" "zx81" "$md_inst/81_libretro.so"
    addSystem "zx81"
}
