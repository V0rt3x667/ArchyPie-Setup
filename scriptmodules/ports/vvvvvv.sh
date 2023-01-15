#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="vvvvvv"
rp_module_desc="VVVVVV: A 2D Puzzle Game"
rp_module_help="Copy 'data.zip' From A Retail Or Make And Play Edition Of VVVVVV To: ${romdir}/ports/vvvvvv"
rp_module_licence="NONCOM https://raw.githubusercontent.com/TerryCavanagh/VVVVVV/master/LICENSE.md"
rp_module_repo="git https://github.com/TerryCavanagh/VVVVVV master"
rp_module_section="opt"

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

    # Set Default Config Path(s)
    applyPatch "${md_data}/01_set_default_config_path.patch"

    # Set Fullscreen By Default
    sed -e "s|_this->fullscreen = false;|_this->fullscreen = true;|g" -i "${md_build}/desktop_version/src/Screen.cpp"

    # Get Latest "gamecontrollerdb.txt" File
    curl -sSL "https://github.com/gabomdq/SDL_GameControllerDB/archive/refs/heads/master.zip" | bsdtar xvf - --strip-components=1 -C "${md_build}"
}

function build_vvvvvv() {
    rpSwap on 1500
    cmake . \
        -Sdesktop_version \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    rpSwap off
    md_ret_require="${md_build}/build/VVVVVV"
}

function install_vvvvvv() {
    md_ret_files=(
        'build/VVVVVV'
        'gamecontrollerdb.txt'
        'LICENSE.md'
    )
}

function configure_vvvvvv() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "/ports/${md_id}"
        # Symlink Game Data
        ln -snf "${romdir}/ports/${md_id}/data.zip" "${md_inst}/data.zip"
    fi

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}"

    addPort "${md_id}" "${md_id}" "VVVVVV" "${md_inst}/VVVVVV"
}
