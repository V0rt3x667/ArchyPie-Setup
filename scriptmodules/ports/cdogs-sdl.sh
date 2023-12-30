#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="cdogs-sdl"
rp_module_desc="C-Dogs SDL: Classic Overhead Run-and-Gun Game"
rp_module_licence="GPL2 https://raw.githubusercontent.com/cxong/cdogs-sdl/master/COPYING"
rp_module_repo="git https://github.com/cxong/cdogs-sdl :_get_branch_cdogs-sdl"
rp_module_section="exp"
rp_module_flags=""

function _get_branch_cdogs-sdl() {
    download "https://api.github.com/repos/cxong/cdogs-sdl/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_cdogs-sdl() {
    local depends=(
        'clang'
        'cmake'
        'enet'
        'libarchive'
        'lld'
        'ninja'
        'sdl2_image'
        'sdl2_mixer'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_cdogs-sdl() {
    gitPullOrClone

    # Download Extra Missions
    download "https://cxong.github.io/${md_id}/missionpack.zip" - | bsdtar xvf - --strip-components=1 -C "${md_build}"

    # Set Default Config Path(s)
    sed "s|\".config/${md_id}/\"|\"ArchyPie/configs/${md_id}/\"|g" -i "${md_build}/CMakeLists.txt"
}

function build_cdogs-sdl() {
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
        -DCDOGS_DATA_DIR="${md_inst}/" \
        -DUSE_SHARED_ENET="ON" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/src/${md_id}"
}

function install_cdogs-sdl() {
    ninja -C build install/strip
}

function configure_cdogs-sdl() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    addPort "${md_id}" "${md_id}" "C-Dogs SDL" "${md_inst}/bin/${md_id} --fullscreen"
}
