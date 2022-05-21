#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="openblok"
rp_module_desc="OpenBlok - A Block Dropping Game"
rp_module_licence="GPL3 https://raw.githubusercontent.com/mmatyas/openblok/master/LICENSE.md"
rp_module_repo="git https://github.com/mmatyas/openblok.git master"
rp_module_section="exp"
rp_module_flags=""

function depends_openblok() { 
    local depends=(
        'cmake'
        'gcc11'
        'gettext'
        'ninja'
        'sdl2_image'
        'sdl2_mixer'
        'sdl2_ttf'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_openblok() {
    gitPullOrClone
}

function build_openblok() {
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DCMAKE_C_COMPILER=gcc-11 \
        -DCMAKE_CXX_COMPILER=g++-11 \
        -DINSTALL_PORTABLE=ON \
        -DENABLE_MP3=OFF
    ninja -C build clean
    ninja -C build
    md_ret_require="$md_build/build/src/openblok"
}

function install_openblok() {
    ninja -C build install/strip
}

function configure_openblok() {
    moveConfigDir "$home/.local/share/openblok" "$md_conf_root/openblok"
    addPort "$md_id" "openblok" "OpenBlok" "$md_inst/openblok"
}
