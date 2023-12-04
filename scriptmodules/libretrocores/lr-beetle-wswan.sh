#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-beetle-wswan"
rp_module_desc="Bandai WonderSwan & WonderSwan Color Libretro Core"
rp_module_help="ROM Extensions: .pc2 .ws .wsc\n\nCopy WonderSwan ROMs To: ${romdir}/wonderswan\n\nCopy WonderSwan Color ROMs To: ${romdir}/wonderswancolor"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/beetle-wswan-libretro/master/COPYING"
rp_module_repo="git https://github.com/libretro/beetle-wswan-libretro master"
rp_module_section="opt"

function sources_lr-beetle-wswan() {
    gitPullOrClone
}

function build_lr-beetle-wswan() {
    make clean
    make
    md_ret_require="${md_build}/mednafen_wswan_libretro.so"
}

function install_lr-beetle-wswan() {
    md_ret_files=('mednafen_wswan_libretro.so')
}

function configure_lr-beetle-wswan() {
    local systems=(
        'wonderswan'
        'wonderswancolor'
    )

    if [[ "${md_mode}" == "install" ]]; then
        for system in "${systems[@]}"; do
            mkRomDir "${system}"
            defaultRAConfig "${system}"
        done
    fi

    for system in "${systems[@]}"; do
        addEmulator 1 "${md_id}" "${system}" "${md_inst}/mednafen_wswan_libretro.so"
        addSystem "${system}"
    done
}
