#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-tic80"
rp_module_desc="TIC-80 Fantasy Computer Libretro Core"
rp_module_help="ROM Extensions: .tic .zip\n\nCopy TIC-80 Games To: ${romdir}/tic80"
rp_module_licence="MIT https://raw.githubusercontent.com/libretro/TIC-80/master/LICENSE"
rp_module_repo="git https://github.com/libretro/TIC-80 master"
rp_module_section="exp"

function depends_lr-tic80() {
    local depends=(
        'cmake'
        'doxygen'
        'libuv'
        'ninja'
    )
    getDepends "${depends[@]}"
}

function sources_lr-tic80() {
    gitPullOrClone
}

function build_lr-tic80() {
    # Cannot Build With Clang Due To Error 'https://github.com/wasm3/wasm3/issues/447'

    cmake . \
        -B"build" \
        -G"Ninja" \
        -S"core" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DBUILD_DEMO_CARTS="OFF" \
        -DBUILD_LIBRETRO="ON" \
        -DBUILD_PLAYER="OFF" \
        -DBUILD_SDL="OFF" \
        -DBUILD_SOKOL="OFF" \
        -DBUILD_TESTING="OFF" \
        -DBUILD_WITH_MRUBY="OFF" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/lib/tic80_libretro.so"
}


function install_lr-tic80() {
    md_ret_files=(
        'build/lib/tic80_libretro.so'
        'LICENSE'
    )
}

function configure_lr-tic80() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "tic80"
        defaultRAConfig "tic80"
    fi

    addEmulator 1 "${md_id}" "tic80" "${md_inst}/tic80_libretro.so"

    addSystem "tic80"
}
