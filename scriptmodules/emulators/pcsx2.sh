#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="pcsx2"
rp_module_desc="PCSX2: Sony PlayStation 2 Emulator"
rp_module_help="ROM Extensions: .bin .bz2 .chd .cso .dump .gz .ima .img .iso .mdf .z .z2\n\nCopy PS2 ROMs To: ${romdir}/ps2\n\nCopy BIOS Files (ps2-0230a-20080220, ps2-0230e-20080220 & ps2-0230j-20080220) To: ${biosdir}/ps2"
rp_module_licence="GPL3 https://raw.githubusercontent.com/PCSX2/pcsx2/master/COPYING.GPLv3"
rp_module_repo="git https://github.com/PCSX2/pcsx2 master"
rp_module_section="main"
rp_module_flags="!all x86_64"

function depends_pcsx2() {
    local depends=(
        'cmake'
        'doxygen'
        'fmt'
        'libaio'
        'libpcap'
        'libzip'
        'ninja'
        'png++'
        'portaudio'
        'p7zip'
        'qt6-base'
        'qt6-svg'
        'qt6-tools'
        'rapidyaml'
        'sdl2'
        'soundtouch'
        'zlib'
    )
    getDepends "${depends[@]}"
}
isPlatform "x11" && depends+=('qt6-wayland')

function sources_pcsx2() {
    gitPullOrClone

    # Set Default Config Path(s)
    applyPatch "${md_data}/01_set_default_config_path.patch"

    # Get Patches & Compress Them
    gitPullOrClone "${md_build}/patches" "https://github.com/PCSX2/pcsx2_patches" "main"
    7z a -r "${md_build}/patches/patches.zip" "${md_build}/patches/patches/."

    # Get Latest "gamecontrollerdb.txt" File
    curl -sSL "https://github.com/gabomdq/SDL_GameControllerDB/archive/refs/heads/master.zip" | bsdtar xvf - --strip-components=1 -C "${md_build}"
}

function build_pcsx2() {
    local params=()
    isPlatform "x11" && params+=(-DWAYLAND_API="ON" -DX11_API="ON")
    isPlatform "kms" && params+=(-DWAYLAND_API="OFF" -DX11_API="OFF")

    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DDISABLE_BUILD_DATE="ON" \
        -DENABLE_TESTS="OFF" \
        -DLTO_PCSX2_CORE="ON" \
        "${params[@]}" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/bin/${md_id}-qt"
}

function install_pcsx2() {
    md_ret_files=(
        "build/bin/pcsx2-qt"
        "build/bin/resources"
        "build/bin/translations"
        "gamecontrollerdb.txt"
    )
    # Install Patch Files
    install -Dm644 "${md_build}/patches/patches.zip" -t "${md_inst}/resources/"
}

function configure_pcsx2() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/ps2/${md_id}"
    
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "ps2"

        mkUserDir "${biosdir}/ps2"
        mkUserDir "${arpdir}/${md_id}/inis"

        # Set Default Config File
        local config
        config="$(mktemp)"
        iniConfig " = " "" "${config}"

        echo "[UI]" > "${config}"
        iniSet "SettingsVersion" "1"
        iniSet "StartFullscreen" "true"
        iniSet "HideMouseCursor" "true"
        iniSet "ConfirmShutdown" "false"
        echo "[GameList]" >> "${config}"
        iniSet "Paths" "${romdir}/ps2"
        echo "[Folders]" >> "${config}"
        iniSet "Bios" "${biosdir}/ps2"

        copyDefaultConfig "${config}" "${md_conf_root}/ps2/${md_id}/inis/PCSX2.ini"
        rm "${config}"
    fi

    addEmulator 1 "${md_id}" "ps2" "${md_inst}/pcsx2-qt -nogui -fullscreen %ROM%"
    addEmulator 0 "${md_id}-gui" "ps2" "${md_inst}/pcsx2-qt -nofullscreen %ROM%"

    addSystem "ps2"
}
