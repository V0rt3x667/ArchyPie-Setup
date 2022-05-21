#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="digger"
rp_module_desc="Digger Remastered"
rp_module_licence="GPL https://raw.githubusercontent.com/sobomax/digger/master/README.md"
rp_module_repo="git https://github.com/proyvind/digger.git joystick"
rp_module_section="exp"

function depends_digger() {
    local depends=(
        'cmake'
        'ninja'
        'sdl2'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_digger() {
    gitPullOrClone
}

function build_digger() {
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="$md_build/build/digger"
}

function install_digger() {
    md_ret_files=('build/digger')
}

function configure_digger() {
    # remove symlink that isn't used
    rm -f "$home/.config/digger"

    # symlink config and hiscore save file
    moveConfigFile "$home/.digger.rc" "$md_conf_root/digger/.digger.rc"
    moveConfigFile "$home/.digger.sco" "$md_conf_root/digger/.digger.sco"
    addPort "$md_id" "digger" "Digger Remastered" "$md_inst/digger /F"
}
