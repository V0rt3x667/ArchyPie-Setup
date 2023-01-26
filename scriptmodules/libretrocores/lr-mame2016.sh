#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-mame2016"
rp_module_desc="MAME 0.174 Libretro Core"
rp_module_help="ROM Extension: .zip\n\nCopy your MAME roms to either $romdir/mame-libretro or\n$romdir/arcade"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/mame2016-libretro/master/LICENSE.md"
rp_module_repo="git https://github.com/libretro/mame2016-libretro master"
rp_module_section="exp"
rp_module_flags=""

function depends_lr-mame2016() {
    local depends=('python' 'zlib')
    getDepends "${depends[@]}"
}

function sources_lr-mame2016() {
    gitPullOrClone
}

function build_lr-mame2016() {
    rpSwap on 1200
    local params=($(_get_params_lr-mame) SUBTARGET=arcade PYTHON_EXECUTABLE=python)
    make -f Makefile.libretro clean
    make -f Makefile.libretro "${params[@]}"
    rpSwap off
    md_ret_require="$md_build/mamearcade2016_libretro.so"
}

function install_lr-mame2016() {
    md_ret_files=(
        'mamearcade2016_libretro.so'
    )
}

function configure_lr-mame2016() {
    local system
    for system in arcade mame-libretro; do
        mkRomDir "$system"
        defaultRAConfig "$system"
        addEmulator 0 "$md_id" "$system" "$md_inst/mamearcade2016_libretro.so"
        addSystem "$system"
    done
}
