#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="vvvvvv"
rp_module_desc="VVVVVV: A 2D Puzzle Game"
rp_module_help="Copy 'data.zip' From A Retail Or Make And Play Edition Of VVVVVV To: ${romdir}/ports/vvvvvv"
rp_module_licence="NONCOM https://raw.githubusercontent.com/TerryCavanagh/VVVVVV/master/LICENSE.md"
rp_module_repo="git https://github.com/TerryCavanagh/VVVVVV :_get_branch_vvvvvv"
rp_module_section="opt"

function _get_branch_vvvvvv() {
    download "https://api.github.com/repos/TerryCavanagh/VVVVVV/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_vvvvvv() {
    local depends=(
        'clang'
        'cmake'
        'faudio'
        'lld'
        'ninja'
        'physfs'
        'sdl2'
        'tinyxml2'
    )
    getDepends "${depends[@]}"
}

function sources_vvvvvv() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|prefDir = PHYSFS_getPrefDir(\"distractionware\", \"VVVVVV\");|prefDir = \"/opt/archypie/configs/ports/vvvvvv/\";|g" -i "${md_build}/desktop_version/src/FileSystemUtils.cpp"

    # Set Fullscreen By Default
    sed -e "s|_this->fullscreen = false;|_this->fullscreen = true;|g" -i "${md_build}/desktop_version/src/Screen.cpp"

    # Get Latest "gamecontrollerdb.txt" File
    curl -sSL "https://github.com/gabomdq/SDL_GameControllerDB/archive/refs/heads/master.zip" | bsdtar xvf - --strip-components=1 -C "${md_build}"
}

function build_vvvvvv() {
    cmake . \
        -B"build" \
        -G"Ninja" \
        -S"desktop_version" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_EXE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_MODULE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_SHARED_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DBUNDLE_DEPENDENCIES="OFF" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/VVVVVV"
}

function install_vvvvvv() {
    md_ret_files=(
        'build/VVVVVV'
        'desktop_version/fonts'
        'desktop_version/lang'
        'gamecontrollerdb.txt'
        'LICENSE.md'
    )
}

function configure_vvvvvv() {
    local portname
    portname="vvvvvv"

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "/ports/${md_id}"

        # Symlink Game Data
        ln -snf "${romdir}/ports/${md_id}/data.zip" "${md_inst}/data.zip"
    fi

    addPort "${md_id}" "${portname}" "VVVVVV" "${md_inst}/VVVVVV"
}
