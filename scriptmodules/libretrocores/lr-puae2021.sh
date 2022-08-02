#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-puae2021"
rp_module_desc="Commodore Amiga 500, 500+, 600, 1200, 4000, CDTV & CD32 Libretro Core (v2.6.1)"
rp_module_help="ROM Extensions: .adf .ipf .lha .uae\n\nCopy Amiga Games to Directory: $romdir/amiga"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/PUAE/master/COPYING"
rp_module_repo="git https://github.com/libretro/libretro-uae.git 2.6.1"
rp_module_section="opt"

function sources_lr-puae2021() {
    gitPullOrClone
    _sources_libcapsimage_fs-uae
}

function build_lr-puae2021() {
    _build_libcapsimage_fs-uae
    make -C "$md_build" clean
    make -C "$md_build"
    md_ret_require="$md_build/puae2021_libretro.so"
}

function install_lr-puae2021() {
    md_ret_files=(
        'README.md'
        'capsimg/CAPSImg/capsimg.so'
        'puae2021_libretro.so'
        'sources/uae_data'
    )
}

function configure_lr-puae2021() {
    mkRomDir "amiga"
    mkRomDir "cd32"
    mkRomDir "cdtv"

    mkUserDir "$biosdir/amiga"
    #mkUserDir "$biosdir/amiga/bios"

    defaultRAConfig "amiga" "system_directory" "$biosdir/amiga"
    defaultRAConfig "cd32" "system_directory" "$biosdir/amiga"
    defaultRAConfig "cdtv" "system_directory" "$biosdir/amiga"

    if [[ ! -f "$biosdir/amiga/bios/capsimg.so" ]]; then
        install -Dm644 "$md_inst/capsimg.so" "$biosdir/amiga"
    fi

    addEmulator 0 "lr-puae2021" "amiga" "$md_inst/puae2021_libretro.so"

    addSystem "amiga"
    addSystem "cd32"
    addSystem "cdtv"
}
