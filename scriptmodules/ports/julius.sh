#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="julius"
rp_module_desc="Julius: Caesar III Port"
rp_module_licence="AGPL3 https://raw.githubusercontent.com/bvschaik/julius/master/LICENSE.txt"
rp_module_repo="git https://github.com/bvschaik/julius :_get_branch_julius"
rp_module_section="opt"
rp_module_flags="!all 64bit"

function _get_branch_julius() {
    download "https://api.github.com/repos/bvschaik/julius/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_julius() {
    local depends=(
        'clang'
        'cmake'
        'libpng'
        'lld'
        'mpg123'
        'ninja'
        'sdl2_mixer'
        'sdl2'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_julius() {
    gitPullOrClone
}

function build_julius() {
    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_EXE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_MODULE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_SHARED_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/${md_id}"
}

function install_julius() {
    ninja -C build install/strip
}

function configure_julius() {
    local portname
    portname="caesar3"

    [[ "${md_mode}" == "install" ]] && mkRomDir "ports/${portname}"

    addPort "${md_id}" "${portname}" "Caesar III" "${md_inst}/bin/${md_id} ${romdir}/ports/${portname}"
}
