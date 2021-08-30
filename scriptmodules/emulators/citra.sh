#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="citra"
rp_module_desc="Citra - Nintendo 3DS Emulator"
rp_module_help="ROM Extensions: .3ds .cci .cxi .app .3dsx\n\nCopy Your Nintendo 3DS Games to $romdir/3ds"
rp_module_licence="GPL2 https://raw.githubusercontent.com/citra-emu/citra/master/license.txt"
rp_module_repo="git https://github.com/libretro/citra.git master"
rp_module_section="main"
rp_module_flags="!all 64bit"

function depends_citra() {
    local depends=(
        'ffmpeg'
        'qt5-multimedia'
        'sdl2'
        'cmake'
        'doxygen'
        'libc++'
    )
    getDepends "${depends[@]}"
}

function sources_citra() {
    gitPullOrClone
}

function build_citra() {
    mkdir build
    cd build
    cmake .. \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DUSE_SYSTEM_CURL=ON \
        -DENABLE_SDL2=ON \
        -DENABLE_QT=ON \
        -DENABLE_WEB_SERVICE=OFF \
        -DCITRA_USE_BUNDLED_SDL2=OFF \
        -DCITRA_USE_BUNDLED_QT=OFF \
        -DENABLE_FFMPEG_AUDIO_DECODER=ON
    make clean
    make
    md_ret_require="$md_build/build/citra"
}

function install_citra() {
    cd build
    make install
}

function configure_citra() {
    mkRomDir "3ds"

    addEmulator 1 "$md_id" "3ds" "$md_inst/bin/citra -f %ROM%"
    addEmulator 0 "$md_id-gui" "3ds" "$md_inst/bin/citra-qt -f %ROM%"

    addSystem "3ds"
}
