#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="smw"
rp_module_desc="Super Mario War: Fan-made Multiplayer Super Mario Bros. Style Deathmatch Game"
rp_module_licence="GPL2 https://smwstuff.net"
rp_module_repo="git https://github.com/mmatyas/supermariowar master"
rp_module_section="opt"
rp_module_flags=""

function depends_smw() {
    local depends=(
        'clang'
        'cmake'
        'enet'
        'lld'
        'ninja'
        'sdl2_image'
        'sdl2_mixer'
        'sdl2'
        'yaml-cpp'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_smw() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|std::string result(\".smw/\");|std::string result(\"ArchyPie/configs/${md_id}/\");|g" -i "${md_build}/src/common/path.cpp"
}

function build_smw() {
    local params=()
    isPlatform "gles2" && params+=('-DSDL2_FORCE_GLES=ON')

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
        -DBUILD_STATIC_LIBS="OFF" \
        -DSMW_INSTALL_PORTABLE="ON" \
        -DUSE_SDL2_LIBS="ON" \
        "${params[@]}" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/${md_id}"
}

function install_smw() {
    ninja -C build install/strip
}

function configure_smw() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}"

    addPort "${md_id}" "${md_id}" "Super Mario War" "${md_inst}/${md_id}"
}
