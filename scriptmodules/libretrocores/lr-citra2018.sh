#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-citra2018"
rp_module_desc="Nintendo 3DS Libretro Core"
rp_module_help="ROM Extensions: .3ds .3dsx .app .cci .cxi\n\nCopy Your Nintendo 3DS ROMs to $romdir/3ds"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/citra2018/master/license.txt"
rp_module_repo="git https://github.com/libretro/citra2018 master"
rp_module_section="opt"
rp_module_flags="!all 64bit"

function depends_lr-citra2018() {
    local depends=(
        'boost'
        'clang'
        'ffmpeg'
        'fmt'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_lr-citra2018() {
    gitPullOrClone
    
    # Fix missing include
    sed '/#include <vector>/a #include <limits>' -i ./src/common/ring_buffer.h

    # Prevent tests from building as they break compilation
    sed -e "s|add_subdirectory(tests)|#add_subdirectory(tests)|g" -i ./src/CMakeLists.txt
}

function build_lr-citra2018() {
    cmake . \
        -Bbuild \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_CXX_COMPILER="clang++" \
        -Wno-dev
    make -C build clean
    make -C build
    md_ret_require="build/src/citra_libretro/citra2018_libretro.so"
}

function install_lr-citra2018() {
    md_ret_files=('build/src/citra_libretro/citra2018_libretro.so')
}

function configure_lr-citra2018() {
    mkRomDir "3ds"

    defaultRAConfig "3ds"

    addEmulator 0 "$md_id" "3ds" "$md_inst/citra2018_libretro.so"
    addSystem "3ds"
}
