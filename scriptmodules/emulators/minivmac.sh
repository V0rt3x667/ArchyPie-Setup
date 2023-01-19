#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="minivmac"
rp_module_desc="Mini vMac: Apple Macintosh Plus Emulator"
rp_module_help="ROM Extensions: .dsk\n\nCopy Macintosh Plus Games To: ${romdir}/macintosh\n\nCopy Macintosh BIOS File (vMac.ROM) To: ${biosdir}/macintosh"
rp_module_licence="GPL2 https://raw.githubusercontent.com/vanfanel/minivmac_sdl2/master/COPYING.txt"
rp_module_repo="file https://www.gryphel.com/d/minivmac/minivmac-36.04/minivmac-36.04.src.tgz"
rp_module_section="exp"
rp_module_flags="!all x11"

function depends_minivmac() {
    local depends=('libx11')
    getDepends "${depends[@]}"
}

function sources_minivmac() {
    downloadAndExtract "${md_repo_url}" "${md_build}" --strip-components 1
}

function build_minivmac() {
    platform=()
    isPlatform "x86" && isPlatform "64bit" && platform=('lx64')
    isPlatform "x86" && isPlatform "32bit" && platform=('lx86')
    isPlatform "arm" && platform=('larm')

    gcc ./setup/tool.c -o setup_t
    ./setup_t -t "${platform[@]}" > ./setup.sh
    chmod a+x ./setup.sh
    ./setup.sh
    make clean
    make
    md_ret_require="${md_build}/${md_id}"
}

function install_minivmac() {
    md_ret_files=("${md_id}")
}

function configure_minivmac() {
    mkRomDir "macintosh"

    ln -sf "${biosdir}/macintosh/vMac.ROM" "${md_inst}/vMac.ROM"

    addEmulator 0 "${md_id}" "macintosh" "${md_inst}/${md_id} %ROM%"

    addSystem "macintosh"
}
