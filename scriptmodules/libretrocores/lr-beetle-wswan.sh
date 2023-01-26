#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-beetle-wswan"
rp_module_desc="Bandai WonderSwan & WonderSwan Color Libretro Core"
rp_module_help="ROM Extensions: .ws .wsc .zip\n\nCopy your Wonderswan roms to $romdir/wonderswan\n\nCopy your Wonderswan Color roms to $romdir/wonderswancolor"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-wswan-libretro/master/COPYING"
rp_module_repo="git https://github.com/libretro/beetle-wswan-libretro master"
rp_module_section="opt"

function sources_lr-beetle-wswan() {
    gitPullOrClone
}

function build_lr-beetle-wswan() {
    make clean
    make
    md_ret_require="$md_build/mednafen_wswan_libretro.so"
}

function install_lr-beetle-wswan() {
    md_ret_files=(
        'mednafen_wswan_libretro.so'
    )
}

function configure_lr-beetle-wswan() {
    mkRomDir "wonderswan"
    mkRomDir "wonderswancolor"
    defaultRAConfig "wonderswan"
    defaultRAConfig "wonderswancolor"

    addEmulator 1 "$md_id" "wonderswan" "$md_inst/mednafen_wswan_libretro.so"
    addEmulator 1 "$md_id" "wonderswancolor" "$md_inst/mednafen_wswan_libretro.so"
    addSystem "wonderswan"
    addSystem "wonderswancolor"
}
