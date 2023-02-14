#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-citra2018"
rp_module_desc="Nintendo 3DS Libretro Core"
rp_module_help="ROM Extensions: .3ds .3dsx .app .axf .cci .cxi .elf\n\nCopy 3DS ROMs To: ${romdir}/3ds"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/citra2018/master/license.txt"
rp_module_repo="git https://github.com/libretro/citra2018 master"
rp_module_section="opt"
rp_module_flags="!all 64bit"

function depends_lr-citra2018() {
    local depends=(
        'boost'
        'ffmpeg'
        'fmt'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_lr-citra2018() {
    gitPullOrClone

    # Fix Missing Include
    sed "/#include <vector>/a #include <limits>/" -i "${md_build}/src/common/ring_buffer.h"

    # Prevent Tests From Building As They Break Compilation
    sed -e "s|add_subdirectory(tests)|#add_subdirectory(tests)|g" -i "${md_build}/src/CMakeLists.txt"
}

function build_lr-citra2018() {
    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="build/src/citra_libretro/citra2018_libretro.so"
}

function install_lr-citra2018() {
    md_ret_files=('build/src/citra_libretro/citra2018_libretro.so')
}

function configure_lr-citra2018() {
    mkRomDir "3ds"

    defaultRAConfig "3ds"

    addEmulator 0 "${md_id}" "3ds" "${md_inst}/citra2018_libretro.so"

    addSystem "3ds"
}
