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
rp_module_flags="!all"

function depends_lr-citra() {
        local depends=(
        'boost'
        'clang'
        'cmake'
        'ffmpeg'
        'fmt'
        'libfdk-aac'
        'ninja'
    )
    getDepends "${depends[@]}"
}

function sources_lr-citra() {
    gitPullOrClone
}

function build_lr-citra() {
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DENABLE_LIBRETRO=ON \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_CXX_FLAGS="${CXXFLAGS} -DFMT_USE_USER_DEFINED_LITERALS=0 -fbracket-depth=649 -fno-lto" \
        -DUSE_SYSTEM_BOOST="ON" \
        -DENABLE_QT=OFF \
        -DENABLE_SDL2=OFF \
        -DENABLE_WEB_SERVICE=OFF \
        -Wno-dev
    ninja -C build
    md_ret_require="build/src/citra_libretro/citra_libretro.so"
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
