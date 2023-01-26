#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-sameboy"
rp_module_desc="Nintendo Game Boy, Game Boy Color & Super Game Boy Libretro Core"
rp_module_help="ROM Extensions: .gb .gbc .zip\n\nCopy Your Game Boy ROMs to $romdir/gb\nGame Boy Color ROMs to $romdir/gbc\nCopy the recommended BIOS files gb_bios.bin and gbc_bios.bin to $biosdir"
rp_module_licence="MIT https://raw.githubusercontent.com/libretro/SameBoy/buildbot/LICENSE"
rp_module_repo="git https://github.com/libretro/SameBoy buildbot"
rp_module_section="opt"

function depends_lr-sameboy() {
    local depends=(
        'clang'
        'glibc'
        'libgl'
        'libglvnd'
        'rgbds'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_lr-sameboy() {
    gitPullOrClone
}

function build_lr-sameboy() {
    make clean
    make -C libretro CONF=release
    md_ret_require="$md_build/libretro/sameboy_libretro.so"
}

function install_lr-sameboy() {
    md_ret_files=(
        'libretro/sameboy_libretro.so'
        'LICENSE'
    )
}

function configure_lr-sameboy() {
    local system
    local def

    for system in gb gbc; do
        def=0
        mkRomDir "$system"
        defaultRAConfig "$system"
        addEmulator "$def" "$md_id" "$system" "$md_inst/sameboy_libretro.so"
        addSystem "$system"
    done
}

