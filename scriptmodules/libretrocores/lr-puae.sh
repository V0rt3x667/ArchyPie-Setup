#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-puae"
rp_module_desc="Commodore Amiga 500, 500+, 600, 1200, 4000, CDTV & CD32 Libretro Core"
rp_module_help="ROM Extensions: .adf .ipf .lha .uae\n\nCopy Amiga Games to Directory: $romdir/amiga"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/PUAE/master/COPYING"
rp_module_repo="git https://github.com/libretro/libretro-uae master"
rp_module_section="opt"

function sources_lr-puae() {
    gitPullOrClone
    _sources_libcapsimage_fs-uae
}

function build_lr-puae() {
    _build_libcapsimage_fs-uae
    cd "$md_build"
    make
    md_ret_require="$md_build/puae_libretro.so"
}

function install_lr-puae() {
    md_ret_files=(
        'puae_libretro.so'
        'README.md'
        'sources/uae_data'
        'capsimg/CAPSImg/capsimg.so'
    )
}

function configure_lr-puae() {
    mkRomDir "amiga"
    defaultRAConfig "amiga"
    addEmulator 1 "$md_id" "amiga" "$md_inst/puae_libretro.so"
    addSystem "amiga"
}
