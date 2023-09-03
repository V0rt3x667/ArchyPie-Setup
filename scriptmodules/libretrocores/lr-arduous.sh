#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-arduous"
rp_module_desc="Arduboy Libretro Core"
rp_module_help="ROM Extensions: .hex .zip\n\nCopy Arduboy Games To: ${romdir}/arduboy"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/arduous/main/COPYING"
rp_module_repo="git https://github.com/libretro/arduous main"
rp_module_section="exp"

function depends_lr-arduous() {
    local depends=(
        'cmake'
        'ninja'
    )
    getDepends "${depends[@]}"
}

function sources_lr-arduous() {
    gitPullOrClone
}

function build_lr-arduous() {
    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/arduous_libretro.so"
}

function install_lr-arduous() {
    md_ret_files=('build/arduous_libretro.so')
}

function configure_lr-arduous() {
    mkRomDir "arduboy"

    defaultRAConfig "arduboy"

    addEmulator 1 "${md_id}" "arduboy" "${md_inst}/arduous_libretro.so"

    addSystem "arduboy"
}
