#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-dosbox-svn"
rp_module_desc="DOSBox SVN Libretro Core"
rp_module_help="ROM Extensions: .bat .com .exe .sh\n\nCopy your DOS games to $ROMDIR/pc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/dosbox-svn/libretro/COPYING"
rp_module_repo="git https://github.com/libretro/dosbox-svn libretro"
rp_module_section="exp"
rp_module_flags=""

function depends_lr-dosbox-svn() {
    local depends=(
        'sdl'
        'sdl_net'
    )
    getDepends "${depends[@]}"
}

function sources_lr-dosbox-svn() {
    gitPullOrClone
}

function build_lr-dosbox-svn() {
    local params=()
    if isPlatform "arm"; then
        params+="WITH_DYNAREC=arm"
    fi
    make -C libretro -f Makefile.libretro clean
    make -C libretro -f Makefile.libretro "${params[@]}"
    md_ret_require="$md_build/libretro/dosbox_svn_libretro.so"
}

function install_lr-dosbox-svn() {
    md_ret_files=(
        'COPYING'
        'libretro/dosbox_svn_libretro.so'
        'README'
    )
}

function configure_lr-dosbox-svn() {
    mkRomDir "pc"
    defaultRAConfig "pc"

    addEmulator 0 "$md_id" "pc" "$md_inst/dosbox_svn_libretro.so"
    addSystem "pc"
}
