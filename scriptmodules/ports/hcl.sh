#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="hcl"
rp_module_desc="Hydra Castle Labyrinth: A Metroidvania Game"
rp_module_licence="GPL2 https://raw.githubusercontent.com/ptitSeb/hydracastlelabyrinth/master/LICENSE"
rp_module_repo="git https://github.com/ptitSeb/hydracastlelabyrinth master"
rp_module_section="opt"

function depends_hcl() {
    local depends=(
        'clang'
        'cmake'
        'lld'
        'ninja'
        'sdl2_mixer'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_hcl() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|\"/.hydracastlelabyrinth/\"|\"/ArchyPie/configs/${md_id}/\"|g" -i "${md_build}/src/game.c" "${md_build}/src/ini.c"
    sed -e "s|\"/.hydracastlelabyrinth\"|\"/ArchyPie/configs/${md_id}\"|g" -i "${md_build}/src/main.c"
}

function build_hcl() {
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
        -DUSE_SDL2="ON" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/${md_id}"
}

function install_hcl() {
    md_ret_files=(
        'build/hcl'
        'data'
    )
}

function configure_hcl() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    addPort "${md_id}" "${md_id}" "Hydra Castle Labyrinth" "pushd ${md_inst}; ${md_inst}/${md_id} -d; popd"
}
