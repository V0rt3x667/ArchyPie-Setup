#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-puae"
rp_module_desc="Commodore Amiga 500, 500+, 600, 1200, 4000, CDTV & CD32 Libretro Core"
rp_module_help="ROM Extensions: .adf .uae\n\nCopy your roms to $romdir/amiga and create configs as .uae"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/PUAE/master/COPYING"
rp_module_repo="git https://github.com/libretro/libretro-uae.git master"
rp_module_section="opt"

function sources_lr-puae() {
    gitPullOrClone
}

function build_lr-puae() {
    #sed -i '/<sys\/sysctl.h>/d' ./retrodep/memory.c
    make
    md_ret_require="$md_build/puae_libretro.so"
}

function install_lr-puae() {
    md_ret_files=(
        'puae_libretro.so'
        'README.md'
    )
}

function configure_lr-puae() {
    mkRomDir "amiga"
    ensureSystemretroconfig "amiga"
    addEmulator 1 "$md_id" "amiga" "$md_inst/puae_libretro.so"
    addSystem "amiga"
}
