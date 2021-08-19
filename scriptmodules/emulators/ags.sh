#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="ags"
rp_module_desc="Adventure Game Studio - Adventure Game Engine"
rp_module_help="ROM Extension: .exe\n\nCopy your Adventure Game Studio roms to $romdir/ags"
rp_module_licence="OTHER https://raw.githubusercontent.com/adventuregamestudio/ags/master/License.txt"
rp_module_repo="git https://github.com/adventuregamestudio/ags.git v.3.5.1.10"
rp_module_section="opt"
rp_module_flags="!mali"

function depends_ags() {
    local depends=('allegro' 'dumb' 'freetype2' 'libogg' 'libtheora' 'libvorbis' 'xorg-server')
    getDepends "${depends[@]}"
}

function sources_ags() {
    gitPullOrClone
}

function build_ags() {
    mkdir build
    cd build
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -Wno-dev
    make clean
    make

#    make -C Engine clean
#    make -C Engine
    md_ret_require="$md_build/build/ags"
}

function install_ags() {
    cd build
    make install
}

function configure_ags() {
    local binary="XINIT:$md_inst/bin/ags"
    local params=("--fullscreen %ROM%")
    if ! isPlatform "x11"; then
        params+=("--gfxdriver software")
    fi

    mkRomDir "ags"

    # install Eawpatches GUS patch set (see: http://liballeg.org/digmid.html)
    if [[ "$md_mode" == "install" ]]; then
        download "http://www.eglebbk.dds.nl/program/download/digmid.dat" - | bzcat >"$md_inst/bin/patches.dat"
    fi

    addEmulator 1 "$md_id" "ags" "$binary ${params[*]}" "Adventure Game Studio" ".exe"

    addSystem "ags"
}
