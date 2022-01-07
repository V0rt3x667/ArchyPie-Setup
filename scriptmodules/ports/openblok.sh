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
    getDepends cmake gettext sdl2 sdl2_image sdl2_mixer sdl2_ttf
}

function sources_openblok() {
    gitPullOrClone
}

function build_openblok() {
    cmake . \
        -DCMAKE_BUILD_TYPE=Release \
        -DINSTALL_PORTABLE=ON \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DENABLE_MP3=OFF
    make clean
    make
    md_ret_require="$md_build/src/openblok"
}

function install_openblok() {
    make install/strip
}

function configure_openblok() {
    moveConfigDir "$home/.local/share/openblok" "$md_conf_root/openblok"
    addPort "$md_id" "openblok" "OpenBlok" "$md_inst/openblok"
}
