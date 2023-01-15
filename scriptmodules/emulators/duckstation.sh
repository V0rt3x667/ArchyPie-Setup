#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="duckstation"
rp_module_desc="DuckStation: Sony PlayStation Emulator"
rp_module_help="ROM Extensions: .bin .chd .cue .img\n\nCopy PSX ROMs To: ${romdir}/psx\n\nCopy BIOS file(s):\n\nps-30a\nps-30e\nps-30j\nscph5500.bin\nscph5501.bin\nscph5502.bin\nTo: ${biosdir}/psx"
rp_module_licence="GPL3 https://raw.githubusercontent.com/stenzek/duckstation/master/LICENSE"
rp_module_section="main"
rp_module_repo="git https://github.com/stenzek/duckstation master"
rp_module_flags="!all arm x86_64"

function depends_duckstation() {
    local depends=(
        'cmake'
        'curl'
        'extra-cmake-modules'
        'libxkbcommon'
        'ninja'
        'qt6-base'
        'qt6-tools'
        'sdl2'
    )
    isPlatform "kms" || isPlatform "wayland" && depends+=('libdrm')
    isPlatform "x11" && depends+=('xorg-xrandr')
    getDepends "${depends[@]}"
}

function sources_duckstation() {
    gitPullOrClone

    # Set Default Config Path(s)
    applyPatch "${md_data}/01_set_default_config_path.patch"

    # Get Latest "gamecontrollerdb.txt" File
    curl -sSL "https://github.com/gabomdq/SDL_GameControllerDB/archive/refs/heads/master.zip" | bsdtar xvf - --strip-components=1 -C "${md_build}"
}

function build_duckstation() {
    local params=()
    # Enabling: ! isPlatform "x11" && params+=(-DUSE_X11="OFF") breaks building DuckStation
    isPlatform "wayland" && params+=(-DUSE_WAYLAND="ON")
    isPlatform "kms" && params+=(-DUSE_DRMKMS="ON")

    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DBUILD_NOGUI_FRONTEND="OFF" \
        -DBUILD_QT_FRONTEND="ON" \
        -DUSE_SDL2="ON" \
        "${params[@]}" \
        -Wno-dev
    ninja -C build clean
    ninja -C build

    md_ret_require=("build/bin/${md_id}-qt")
}

function install_duckstation() {
    md_ret_files=(
        "build/bin/${md_id}-qt"
        "build/bin/resources"
        "build/bin/translations"
        "gamecontrollerdb.txt"
    )
}

function configure_duckstation() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/psx/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "psx"
        mkUserDir "${biosdir}/psx"
        ln -sf "${biosdir}/psx" "${md_conf_root}/psx/${md_id}/bios"
    fi

    addEmulator 1 "${md_id}" "psx" "${md_inst}/${md_id}-qt -nogui -batch -fullscreen %ROM%"
    addEmulator 0 "${md_id}-gui" "psx" "${md_inst}/${md_id}-qt -fullscreen"

    addSystem "psx"
}
