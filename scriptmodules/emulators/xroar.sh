#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="xroar"
rp_module_desc="XRoar: Dragon Data Dragon 32, 64 & Tandy Colour Computer (CoCo) 1, 2, 3 Emulator"
rp_module_help="ROM Extensions: .asc .bas .cas .ccc .dmk .dsk .jvc .os9 .rom .sna .vdk .wav\n\nCopy Dragon Games To: ${romdir}/dragon32\nCopy CoCo Games To: ${romdir}/coco\n\nCopy Dragon BIOS File (d32.rom) To: ${biosdir}/dragon32\n\nCopy CoCo BIOS Files (bas13.rom, coco3.rom, coco3p.rom) To: ${biosdir}/coco"
rp_module_licence="GPL3 http://www.6809.org.uk/xroar/"
rp_module_repo="git http://www.6809.org.uk/git/xroar.git 1.3"
rp_module_section="opt"
rp_module_flags=""

function depends_xroar() {
    local depends=(
        'alsa-lib'
        'sdl2'
        'texinfo'
        'zlib'
    )
    isPlatform "x11" && depends+=('libpulse')
    getDepends "${depends[@]}"
}

function sources_xroar() {
    gitPullOrClone "${md_build}" "${md_repo_url}" "${md_repo_branch}" "" 0

    # Set Default Config Path(s)
    sed -e "s|-DCONFPATH=\"~/.xroar:|-DCONFPATH=\"~/ArchyPie/configs/xroar:|g" -i "${md_build}/src/Makefile.am"

}

function build_xroar() {
    local params=('--without-gtk2' '--without-gtkgl' '--without-oss')
    if ! isPlatform "x11"; then
        params+=('--without-pulse' '--without-x')
    fi
    ./autogen.sh
    ./configure --prefix="${md_inst}" "${params[@]}"
    make clean
    make
    md_ret_require="${md_build}/src/${md_id}"
}

function install_xroar() {
    make install
}

function configure_xroar() {
    mkRomDir "dragon32"
    mkRomDir "coco"

    mkUserDir "${biosdir}/dragon32"
    mkUserDir "${biosdir}/coco"

    local params=()
    ! isPlatform "x11" && params+=('-vo sdl' '-ccr simple')
    ! isPlatform "rpi" && params+=('-fs')
    addEmulator 1 "${md_id}}-dragon32" "dragon32" "${md_inst}/bin/${md_id} ${params[*]} -machine dragon32 -rompath ${biosdir}/dragon32 -run %ROM%"
    addEmulator 1 "${md_id}-cocous" "coco" "${md_inst}/bin/${md_id} ${params[*]} -machine cocous -rompath ${biosdir}/coco -run %ROM%"
    addEmulator 0 "${md_id}-coco" "coco" "${md_inst}/bin/${md_id} ${params[*]} -machine coco -rompath ${biosdir}/coco -run %ROM%"
    addEmulator 0 "${md_id}-coco3us" "coco" "${md_inst}/bin/${md_id} ${params[*]} -machine coco3 -rompath ${biosdir}/coco -run %ROM%"
    addEmulator 0 "${md_id}-coco3" "coco" "${md_inst}/bin/${md_id} ${params[*]} -machine coco3p -rompath ${biosdir}/coco  -run %ROM%"

    addSystem "dragon32"
    addSystem "coco"
}
