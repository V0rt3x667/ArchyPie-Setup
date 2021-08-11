#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE.md file at the top-level directory of this distribution.

rp_module_id="lr-play"
rp_module_desc="Sony PlayStation 2 Libretro Core"
rp_module_help="ROM Extensions: .iso .cue\n\nCopy Your PlayStation 2 ROMs to $romdir/ps2"
rp_module_licence="MIT https://raw.githubusercontent.com/jpd002/Play-/master/License.txt"
rp_module_repo="git https://github.com/jpd002/Play-.git master"
rp_module_section="exp"
rp_module_flags="!all 64bit"

function depends_lr-play() {
    local depends=(glew)
    getDepends "${depends[@]}"
}

function sources_lr-play() {
    gitPullOrClone
}

function build_lr-play() {
    mkdir build
    cd build
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_LIBRETRO_CORE=ON \
        -DBUILD_PLAY=OFF \
        -DBUILD_TESTS=OFF \
        -DENABLE_AMAZON_S3=OFF
    make clean
    make
    md_ret_require="$md_build/build/play_libretro.so"
}

function install_lr-play() {
    cd build
    md_ret_files=('play_libretro.so' 'License.txt')
}

function configure_lr-play() {
  mkRomDir "ps2"

  ensureSystemretroconfig "ps2"

  addEmulator 0 "$md_id" "ps2" "$md_inst/play_libretro.so"
  addSystem "ps2"
}
