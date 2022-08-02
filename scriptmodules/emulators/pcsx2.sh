#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="pcsx2"
rp_module_desc="PCSX2 - Sony PlayStation 2 Emulator"
rp_module_help="ROM Extensions: .bin .bz2 .chd .cso .dump .gz .ima .img .iso .mdf .z .z2\n\nCopy Your PS2 ROMs to: $romdir/ps2\n\nCopy the required BIOS file to: $biosdir"
rp_module_licence="GPL3 https://raw.githubusercontent.com/PCSX2/pcsx2/master/COPYING.GPLv3"
rp_module_repo="git https://github.com/PCSX2/pcsx2 master"
rp_module_section="main"
rp_module_flags="!all x86"

function depends_pcsx2() {
    local depends=(
        'cmake'
        'doxygen'
        'fmt'
        'libaio'
        'libpcap'
        'ninja'
        'png++'
        'portaudio'
        'qt6-base'
        'qt6-tools'
        'rapidyaml'
        'sdl2'
        'soundtouch'
    )

    getDepends "${depends[@]}"
}

function sources_pcsx2() {
    gitPullOrClone

    applyPatch "$md_data/01_set_default_config_path.patch"
}

function build_pcsx2() {
    # For future use.
    #local params=()
    #isPlatform wayland && params+=('-DWAYLAND_API=ON')

    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DENABLE_TESTS=OFF \
        -DDISABLE_BUILD_DATE=ON \
        -DDISABLE_PCSX2_WRAPPER=ON \
        -DUSE_VTUNE=OFF \
        -DUSE_SYSTEM_LIBS=ON \
        -DXDG_STD=ON \
        -DQT_BUILD=ON \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="$md_build/build/pcsx2-qt/pcsx2-qt"
}

function install_pcsx2() {
    md_ret_files=(
        'build/pcsx2-qt/pcsx2-qt'
        'build/pcsx2-qt/resources'
    )
    ln -svf "$md_inst/pcsx2-qt" "$md_inst/pcsx2"
}

function configure_pcsx2() {
    mkRomDir "ps2"

    mkUserDir "$biosdir/ps2"
    mkUserDir "$arpiedir/emulators"
    mkUserDir "$arpiedir/emulators/$md_id"
    mkUserDir "$arpiedir/emulators/$md_id/inis"

    moveConfigDir "$arpiedir/emulators/$md_id" "$md_conf_root/ps2/$md_id"

    addEmulator 1 "$md_id" "ps2" "$md_inst/pcsx2 %ROM%"
    addEmulator 0 "$md_id-gui" "ps2" "$md_inst/pcsx2"

    addSystem "ps2"

    [[ "$md_mode" == "remove" ]] && return

    # Set default settings.
    local config="$(mktemp)"
    iniConfig " = " "" "$config"
    echo "[UI]" > "$config"
    iniSet "SettingsVersion" "1"
    iniSet "StartFullscreen" "true"
    iniSet "HideMouseCursor" "true"
    iniSet "ConfirmShutdown" "false"
    echo "[GameList]" >> "$config"
    iniSet "Paths" "$romdir/ps2"
    echo "[Folders]" >> "$config"
    iniSet "Bios" "$biosdir/ps2"
    copyDefaultConfig "$config" "$md_conf_root/ps2/$md_id/inis/PCSX2.ini"
    rm "$config"
}
