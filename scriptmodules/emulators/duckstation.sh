#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="duckstation"
rp_module_desc="DuckStation: Sony PlayStation Emulator"
rp_module_help="ROM Extensions: .bin .chd .cue .img\n\nCopy PSX ROMs To: ${romdir}/psx\n\nCopy BIOS Files: scph5500.bin, scph5501.bin & scph5502.bin To: ${biosdir}/psx"
rp_module_licence="GPL3 https://raw.githubusercontent.com/stenzek/duckstation/master/LICENSE"
rp_module_section="main"
rp_module_repo="git https://github.com/stenzek/duckstation master"
rp_module_flags="!all arm x86_64"

function depends_duckstation() {
    local depends=(
        'clang'
        'cmake'
        'curl'
        'libxkbcommon'
        'lld'
        'ninja'
        'qt6-base'
        'qt6-svg'
        'qt6-tools'
        'sdl2'
    )
    isPlatform "kms" && depends+=('libdrm')
    isPlatform "x11" && depends+=(
        'extra-cmake-modules'
        'libx11'
        'qt6-wayland'
        'wayland-protocols'
        'wayland'
        'xorg-xrandr'
    )
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
    isPlatform "kms" && params+=(-DENABLE_WAYLAND="OFF" -DENABLE_X11="OFF")
    ! isPlatform "vulkan" && params+=(-DENABLE_VULKAN="OFF")
    isPlatform "x11" && params+=(-DENABLE_WAYLAND="ON" -DENABLE_X11="ON")

    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_EXE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_MODULE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_SHARED_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DBUILD_NOGUI_FRONTEND="OFF" \
        -DBUILD_QT_FRONTEND="ON" \
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

        # Create Default Configuration File
        local config
        config="$(mktemp)"

        iniConfig " = " "" "${config}"

        # Set ROM Path For GUI
        echo "[GameList]" >> "${config}"
        iniSet "RecursivePaths" "${romdir}/psx"
        # Disable AutoUpdater
        echo "[AutoUpdater]" >> "${config}"
        iniSet "CheckAtStartup" "false"

        copyDefaultConfig "${config}" "${arpdir}/${md_id}/settings.ini"
        rm "${config}"
    fi

    addEmulator 1 "${md_id}" "psx" "${md_inst}/${md_id}-qt -nogui -batch -fullscreen %ROM%"
    addEmulator 0 "${md_id}-gui" "psx" "${md_inst}/${md_id}-qt -fullscreen"

    addSystem "psx"
}
