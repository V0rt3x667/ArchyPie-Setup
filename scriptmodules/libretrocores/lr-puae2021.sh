#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-puae2021"
rp_module_desc="Commodore Amiga 500, 500+, 600, 1200, 4000, CDTV & CD32 Libretro Core (v2.6.1)"
rp_module_help="ROM Extensions: .7z .adf .adz .ccd .chd .cue .dms .fdi .hdf .hdz .info .ipf .iso .lha .m3u .mds .nrg .slave .uae .zip\n\nCopy Amiga Games To: ${romdir}/amiga\nCopy CD32 Games To: ${romdir}/amigacd32\nCopy CDTV Games To: ${romdir}/amigacdtv\n\nCopy BIOS Files:\n\nkick34005.A500\nkick40063.A600\nkick40068.A1200\nkick40060.CD32\nkick34005.CDTV\n\nTo: ${biosdir}/amiga"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/PUAE/master/COPYING"
rp_module_repo="git https://github.com/libretro/libretro-uae 2.6.1"
rp_module_section="opt"

function sources_lr-puae2021() {
    sources_lr-puae
}

function build_lr-puae2021() {
    make clean
    make
    md_ret_require="${md_build}/puae2021_libretro.so"
}

function install_lr-puae2021() {
    md_ret_files=(
        'capsimg/Linux/x86-64/capsimg.so'
        'puae2021_libretro.so'
        'sources/uae_data'
    )
}

function configure_lr-puae2021() {
    configure_lr-puae "puae2021_libretro.so"
}
