#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="snes9x"
rp_module_desc="SNES9X - Nintendo SNES Emulator"
rp_module_help="ROM Extensions: .bin .smc .sfc .fig .swc .mgd .zip\n\nCopy your SNES roms to $romdir/snes"
rp_module_licence="NONCOM https://raw.githubusercontent.com/snes9xgit/snes9x/master/LICENSE"
rp_module_repo="git https://github.com/snes9xgit/snes9x master"
rp_module_section="main"
rp_module_flags="!all x86"

function depends_snes9x() {
    local depends=(
        'alsa-lib'
        'boost-libs'
        'libpulse'
        'libx11'
        'libxv'
        'minizip'
        'portaudio'
        'sdl2'
        'sdl2_ttf'
    )
    getDepends "${depends[@]}"
}

function sources_snes9x() {
    gitPullOrClone
}

function build_snes9x() {
    cd unix
    CXXFLAGS+=" -I/usr/include/glslang"
    autoconf
    ./configure \
        --prefix="$md_inst" \
        --enable-netplay
    make clean
    make
    md_ret_require="$md_build/unix/snes9x"
}

function install_snes9x() {
    md_ret_files=(
        'unix/snes9x'
        'docs'
        'LICENSE'
    )
}

function configure_snes9x() {
    mkRomDir "snes"

    moveConfigDir "$home/.config/snes9x" "$md_conf_root/snes/snes9x"

    addEmulator 1 "$md_id" "snes" "$md_inst/snes9x -fullscreen %ROM%"
    addSystem "snes"
}
