#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="digger"
rp_module_desc="Digger Reloaded: Port of Digger Remastered"
rp_module_licence="GPL2 https://raw.githubusercontent.com/sobomax/digger/refs/heads/master/pkg/windows/LICENSE"
rp_module_repo="git https://github.com/sobomax/digger master"
rp_module_section="exp"
rp_module_flags="all"

function depends_digger() {
    local depends=(
        'clang'
        'cmake'
        'lld'
        'ninja'
        'sdl2'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_digger() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|/.digger.rc|/ArchyPie/configs/${md_id}/digger.rc|g" -i "${md_build}/def.h"
    sed -e "s|/.digger.sco|/ArchyPie/configs/${md_id}/digger.sco|g" -i "${md_build}/scores.c"
}

function build_digger() {
    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_LINKER_TYPE="LLD" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/${md_id}"
}

function install_digger() {
    md_ret_files=('build/digger')
}

function configure_digger() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}"

    addPort "${md_id}" "${md_id}" "Digger Remastered" "${md_inst}/${md_id} /F"
}
