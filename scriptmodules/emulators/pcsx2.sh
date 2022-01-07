#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="pcsx2"
rp_module_desc="PCSX2 - Sony PlayStation 2 Emulator"
rp_module_help="ROM Extensions: .bin .iso .img .mdf .z .z2 .bz2 .cso .ima .gz\n\nCopy your PS2 roms to $romdir/ps2\n\nCopy the required BIOS file to $biosdir"
rp_module_licence="GPL3 https://raw.githubusercontent.com/PCSX2/pcsx2/master/COPYING.GPLv3"
rp_module_repo="git https://github.com/PCSX2/pcsx2.git master"
rp_module_section="exp"
rp_module_flags="!all x86"

function depends_pcsx2() {
    local depends=(
        'clang'
        'cmake'
        'fmt'
        'libaio'
        'ninja'
        'png++'
        'portaudio'
        'sdl2'
        'soundtouch'
        'wxgtk3'
    )
    getDepends "${depends[@]}"
}

function sources_pcsx2() {
    gitPullOrClone
}

function build_pcsx2() {
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_CXX_COMPILER=clang++ \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DENABLE_TESTS=OFF \
        -DDISABLE_BUILD_DATE=ON \
        -DDISABLE_PCSX2_WRAPPER=ON \
        -DSDL2_API=ON \
        -DUSE_VTUNE=OFF \
        -DUSE_SYSTEM_YAML=OFF \
        -DPACKAGE_MODE=ON \
        -DXDG_STD=ON \
        -DwxWidgets_CONFIG_EXECUTABLE=/usr/bin/wx-config-gtk3 \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="$md_build/build/pcsx2/pcsx2"
}

function install_pcsx2() {
    ninja -C build install/strip
}

function configure_pcsx2() {
    mkRomDir "ps2"
    moveConfigDir "$home/.config/PCSX2" "$md_conf_root/ps2"
    ln -svf "$md_conf_root/ps2/bios/" "$biosdir/ps2"
    # Windowed option
    addEmulator 0 "$md_id" "ps2" "$md_inst/bin/pcsx2 %ROM% --windowed"
    # Fullscreen option with no gui (default, because we can close with `Esc` key, easy to map for gamepads)
    addEmulator 1 "$md_id-nogui" "ps2" "$md_inst/bin/pcsx2 %ROM% --fullscreen --nogui"
    addSystem "ps2"
}
