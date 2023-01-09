#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="basilisk"
rp_module_desc="BasiliskII: Apple Macintosh II Emulator"
rp_module_help="ROM Extensions: .img .rom\n\nCopy Macintosh Games To: ${romdir}/macintosh"
rp_module_licence="GPL2 https://raw.githubusercontent.com/cebix/macemu/master/BasiliskII/COPYING"
rp_module_repo="git https://github.com/kanjitalk755/macemu.git master"
rp_module_section="opt"
rp_module_flags="!mali"

function depends_basilisk() {
    local depends=('sdl2' 'vde2')
    isPlatform "x11" && depends+=('gtk2')
    getDepends "${depends[@]}"
}

function sources_basilisk() {
    gitPullOrClone
}

function build_basilisk() {
    cd BasiliskII/src/Unix || exit
    local params=(
        '--disable-vosf'
        '--enable-sdl-audio'
        '--enable-sdl-video'
        '--with-bincue'
        '--with-vdeplug'
        '--without-esd'
        '--without-mon'
    )
    ! isPlatform "x86" && params+=('--disable-jit-compiler')
    ! isPlatform "x11" && params+=('--without-x' '--without-gtk')
    isPlatform "aarch64" && params+=('--build=arm')
    ./autogen.sh --prefix="${md_inst}" "${params[@]}"
    make clean
    make
    md_ret_require="${md_build}/BasiliskII/src/Unix/BasiliskII"
}

function install_basilisk() {
    make -C BasiliskII/src/Unix install
}

function configure_basilisk() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "macintosh"
        touch "${romdir}/macintosh/Start.txt"
    fi

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/macintosh/"

    local params=(
        "--config ${md_conf_root}/macintosh/basiliskii.cfg"
        "--disk ${romdir}/macintosh/disk.img"
        "--extfs ${romdir}/macintosh"
        "--rom ${romdir}/macintosh/mac.rom"
    )

    addEmulator 1 "${md_id}" "macintosh" "${md_inst}/bin/BasiliskII ${params[*]}"

    addSystem "macintosh"
}
