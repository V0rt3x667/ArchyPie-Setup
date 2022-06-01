#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="supertuxkart"
rp_module_desc="SuperTuxKart - 3D Kart Racing Game Featuring Tux & Friends"
rp_module_licence="GPL3 https://raw.githubusercontent.com/supertuxkart/stk-code/master/COPYING"
rp_module_repo="git https://github.com/supertuxkart/stk-code.git master"
rp_module_section="opt"

function depends_supertuxkart() {
    local depends=(
        'bluez-libs'
        'cmake'
        'curl'
        'freetype2'
        'fribidi'
        'glew'
        'glu'
        'libjpeg-turbo'
        'libpng'
        'libraqm'
        'libvorbis'
        'libvpx'
        'libxkbcommon-x11'
        'mcpp'
        'mesa-libgl'
        'mesa'
        'ninja'
        'openal'
        'openssl'
        'sdl2'
        'sqlite'
        'subversion'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_supertuxkart() {
    gitPullOrClone "$md_build/stk-code"
    svn checkout https://svn.code.sf.net/p/supertuxkart/code/stk-assets "$md_build/stk-assets"
}

function build_supertuxkart() {
    cmake . \
        -Sstk-code \
        -GNinja \
        -Bbuild \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DBUILD_RECORDER=0 \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="$md_build/build/bin/supertuxkart"
}

function install_supertuxkart() {
    ninja -C build install/strip
}

function configure_supertuxkart() {
    addPort "$md_id" "supertuxkart" "SuperTuxKart" "$md_inst/bin/supertuxkart -f"

    moveConfigDir "$home/.local/share/supertuxkart" "$md_conf_root/supertuxkart"
}
