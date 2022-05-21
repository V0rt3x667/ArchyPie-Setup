#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="vvvvvv"
rp_module_desc="VVVVVV - 2D Puzzle Game"
rp_module_licence="NONCOM https://raw.githubusercontent.com/TerryCavanagh/VVVVVV/master/LICENSE.md"
rp_module_repo="git https://github.com/TerryCavanagh/VVVVVV master"
rp_module_help="Copy data.zip from a purchased or Make and Play edition of VVVVVV to $romdir/ports/vvvvvv"
rp_module_section="exp"

function depends_vvvvvv() {
        local depends=(
        'cmake'
        'ninja'
        'sdl2_mixer'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_vvvvvv() {
    gitPullOrClone
    # default to fullscreen
    sed -i "s/fullscreen = false/fullscreen = true/" "$md_build/desktop_version/src/Game.cpp"
}

function build_vvvvvv() {
    rpSwap on 1500
    cmake . \
        -Sdesktop_version \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    rpSwap off
    md_ret_require="$md_build/build/VVVVVV"
}

function install_vvvvvv() {
    md_ret_files=(
        'build/VVVVVV'
        'LICENSE.md'
    )
}

function configure_vvvvvv() {
    addPort "$md_id" "vvvvvv" "VVVVVV" "$md_inst/VVVVVV"

    [[ "$md_mode" != "install" ]] && return

    moveConfigDir "$home/.local/share/VVVVVV" "$md_conf_root/vvvvvv"

    mkUserDir "$romdir/ports/$md_id"
    # symlink game data
    ln -snf "$romdir/ports/$md_id/data.zip" "$md_inst/data.zip"
}
