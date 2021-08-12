#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-citra"
rp_module_desc="Nintendo 3DS Libretro Core"
rp_module_help="ROM Extensions: .3ds .3dsx .app .cci .cxi\n\nCopy Your Nintendo 3DS ROMs to $romdir/3ds"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/citra/master/license.txt"
rp_module_repo="git https://github.com/libretro/citra.git master"
rp_module_section="opt"
rp_module_flags="!all 64bit"

function depends_lr-citra() {
    depends_citra
}

function sources_lr-citra() {
    gitPullOrClone
}

function build_lr-citra() {
    mkdir build
    cd build
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DENABLE_LIBRETRO=ON \
        -DENABLE_QT=OFF \
        -DENABLE_SDL2=ON \
        -DENABLE_WEB_SERVICE=OFF
    make clean
    make
    md_ret_require="$md_build/build/src/citra_libretro/citra_libretro.so"
}

function install_lr-citra() {
    md_ret_files=('build/src/citra_libretro/citra_libretro.so')
}

function configure_lr-citra() {
    mkRomDir "3ds"

    ensureSystemretroconfig "3ds"

    addEmulator 0 "$md_id" "3ds" "$md_inst/citra_libretro.so"
    addSystem "3ds"
}
