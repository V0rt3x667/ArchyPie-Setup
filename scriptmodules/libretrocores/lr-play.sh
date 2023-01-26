#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE.md file at the top-level directory of this distribution.

rp_module_id="lr-play"
rp_module_desc="Sony PlayStation 2 Libretro Core"
rp_module_help="ROM Extensions: .iso .cue\n\nCopy Your PlayStation 2 ROMs to $romdir/ps2"
rp_module_licence="MIT https://raw.githubusercontent.com/jpd002/Play-/master/License.txt"
rp_module_repo="git https://github.com/jpd002/Play- master"
rp_module_section="exp"
rp_module_flags="!all 64bit"

function depends_lr-play() {
    local depends=(
        'bzip2'
        'glew'
        'glibc'
        'icu'
        'libgl'
        'libglvnd'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_lr-play() {
    gitPullOrClone
    # Add missing include: #include <string.h>
    find Source/{ee,iop} -type f -name "*" -exec sed -i '1i#include <string.h>' {} +
}

function build_lr-play() {
    cmake . \
        -GNinja \
        -Bbuild \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DBUILD_LIBRETRO_CORE=ON \
        -DBUILD_PLAY=OFF \
        -DBUILD_TESTS=OFF \
        -DENABLE_AMAZON_S3=OFF \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="$md_build/build/Source/ui_libretro/play_libretro.so"
}

function install_lr-play() {
    md_ret_files=(
        'build/Source/ui_libretro/play_libretro.so'
        'License.txt'
    )
}

function configure_lr-play() {
    mkRomDir "ps2"

    defaultRAConfig "ps2"

    addEmulator 0 "$md_id" "ps2" "$md_inst/play_libretro.so"
    addSystem "ps2"
}
