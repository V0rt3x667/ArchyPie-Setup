#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-dirksimple"
rp_module_desc="Super Multiple Arcade Laserdisc Libretro Core"
rp_module_help="ROM Extensions: .dirksimple .ogv\n\nCopy Laserdisc Movies In Ogg Theora Format To ${romdir}/daphne"
rp_module_licence="zlib https://raw.githubusercontent.com/icculus/DirkSimple/main/LICENSE.txt"
rp_module_repo="git https://github.com/icculus/DirkSimple.git main"
rp_module_section="exp"

function depends_lr-dirksimple() {
    local depends=(
        'clang'
        'cmake'
        'lld'
        'ninja'
    )
    getDepends "${depends[@]}"
}

function sources_lr-dirksimple() {
    gitPullOrClone
}

function build_lr-dirksimple() {
    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_EXE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_MODULE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_SHARED_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DDIRKSIMPLE_LIBRETRO="ON" \
        -DDIRKSIMPLE_SDL="OFF" \
        -Wno-dev
    ninja -C build clean
    ninja -C build

    md_ret_require="${md_build}/build/dirksimple_libretro.so"
}

function install_lr-dirksimple() {
    md_ret_files=(
        'build/dirksimple_libretro.so'
        'data'
        'LICENSE.txt'
    )
}

function configure_lr-dirksimple() {
    if [[ "${md_mode}" == "install" ]]; then
        defaultRAConfig "daphne"

        mkRomDir "daphne"
        mkUserDir "${biosdir}/daphne"
        mkUserDir "${biosdir}/daphne/DirkSimple"

        # Copy Data To BIOS Directory
        cp -rf "${md_inst}/data" "${biosdir}/daphne/DirkSimple"
        chown -R "${user}:${user}" "${biosdir}/daphne"
    fi

    addEmulator 0 "${md_id}" "daphne" "${md_inst}/dirksimple_libretro.so"

    addSystem "daphne"
}
