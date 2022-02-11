#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-ppsspp"
rp_module_desc="Sony PlayStation Portable Libretro Core"
rp_module_help="ROM Extensions: .iso .pbp .cso\n\nCopy your PlayStation Portable roms to $romdir/psp"
rp_module_licence="GPL2 https://raw.githubusercontent.com/RetroPie/ppsspp/master/LICENSE.TXT"
rp_module_repo="git https://github.com/hrydgard/ppsspp.git master"
rp_module_section="opt"
rp_module_flags=""

function depends_lr-ppsspp() {
    depends_ppsspp
}

function sources_lr-ppsspp() {
    sources_ppsspp
}

function build_lr-ppsspp() {
    build_ppsspp
}

function install_lr-ppsspp() {
    md_ret_files=(
        'build/lib/ppsspp_libretro.so'
        'assets'
    )
}

function configure_lr-ppsspp() {
    mkRomDir "psp"
    ensureSystemretroconfig "psp"

    if [[ "$md_mode" == "install" ]]; then
        mkUserDir "$biosdir/PPSSPP"
        cp -Rv "$md_inst/assets/"* "$biosdir/PPSSPP/"
        chown -R $user:$user "$biosdir/PPSSPP"
    fi

    addEmulator 1 "$md_id" "psp" "$md_inst/ppsspp_libretro.so"
    addSystem "psp"
}
