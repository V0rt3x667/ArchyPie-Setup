#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-dolphin"
rp_module_desc="Nintendo Gamecube & Wii Libretro Core"
rp_module_help="ROM Extensions: .gcm .iso .wbfs .ciso .gcz\n\nCopy your Gamecube roms to $romdir/gc and Wii roms to $romdir/wii"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/dolphin/master/license.txt"
rp_module_repo="git https://github.com/libretro/dolphin master"
rp_module_section="exp"
rp_module_flags="!all 64bit"

function depends_lr-dolphin() {
    local depends=(
        'gcc10'
        'bluez-libs'
        'enet'
        'ffmpeg'
        'lzo'
        'mbedtls'
        'miniupnpc'
        'pugixml'
        'qt5-base'
        'sfml'
        'cmake'
    )
    getDepends "${depends[@]}"
}

function sources_lr-dolphin() {
    gitPullOrClone
}

function build_lr-dolphin() {
    mkdir build
    cd build
    export CC="gcc-10" CXX="g++-10"
    cmake .. \
        -DLIBRETRO_STATIC=1 \
        -DCMAKE_BUILD_TYPE=Release \
        -DENABLE_LTO=ON \
        -DENABLE_NOGUI=OFF \
        -DENABLE_QT=OFF \
        -DENABLE_TESTS=OFF \
        -DLIBRETRO=ON \
        -DUSE_SHARED_ENET=ON \
        -Wno-dev
    make clean
    make
    export CC="gcc" CXX="g++"
    md_ret_require="$md_build/build/dolphin_libretro.so"
}

function install_lr-dolphin() {
    md_ret_files=(
        'build/dolphin_libretro.so'
        'Data/Sys'
    )
}

function configure_lr-dolphin() {
    mkRomDir "gc"
    mkRomDir "wii"

    ensureSystemretroconfig "gc"
    ensureSystemretroconfig "wii"

    mkdir $biosdir/dolphin-emu
    ln -sf $md_inst/Sys $biosdir/dolphin-emu/

    addEmulator 0 "$md_id" "gc" "$md_inst/dolphin_libretro.so"
    addEmulator 0 "$md_id" "wii" "$md_inst/dolphin_libretro.so"

    addSystem "gc"
    addSystem "wii"
}
