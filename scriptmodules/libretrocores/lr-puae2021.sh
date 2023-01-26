#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-puae2021"
rp_module_desc="Commodore Amiga 500, 500+, 600, 1200, 4000, CDTV & CD32 Libretro Core (v2.6.1)"
rp_module_help="ROM Extensions: .adf .ipf .lha .uae\n\nCopy Amiga Games to Directory: $romdir/amiga"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/PUAE/master/COPYING"
rp_module_repo="git https://github.com/libretro/libretro-uae 2.6.1"
rp_module_section="opt"

function sources_lr-puae2021() {
    gitPullOrClone
}

function build_lr-puae2021() {
    make
    md_ret_require="$md_build/puae2021_libretro.so"
}

function install_lr-puae2021() {
    md_ret_files=(
        'puae2021_libretro.so'
        'README.md'
    )
}

function configure_lr-puae2021() {
    mkRomDir "amiga"
    defaultRAConfig "amiga"
    addEmulator 1 "lr-puae2021" "amiga" "$md_inst/puae2021_libretro.so"
    addSystem "amiga"
}
