#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="supertux"
rp_module_desc="SuperTux: Classic 2D Jump'n'Run Sidescroller Game"
rp_module_licence="GPL3 https://raw.githubusercontent.com/SuperTux/supertux/master/LICENSE.txt"
rp_module_repo="git https://github.com/SuperTux/supertux :_get_branch_supertux"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_supertux() {
    download "https://api.github.com/repos/supertux/supertux/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_supertux() {
    local depends=(
        'boost-libs'
        'boost'
        'clang'
        'cmake'
        'curl'
        'doxygen'
        'freetype2'
        'fribidi'
        'glew'
        'harfbuzz'
        'libraqm'
        'libvorbis'
        'lld'
        'mesa'
        'ninja'
        'openal'
        'optipng'
        'physfs'
        'sdl2_image'
        'sdl2'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_supertux() {
    gitPullOrClone

    # Fix Build
    sed "1i#include <memory>" -i "${md_build}/external/partio_zip/zip_manager.cpp"
}

function build_supertux() {
    local params=()

    isPlatform "arm" && params+=("-DENABLE_OPENGLES2")

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
        -DINSTALL_SUBDIR_BIN="bin" \
        "${params[@]}" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/supertux2"
}

function install_supertux() {
    ninja -C build install/strip
}

function configure_supertux() {
    local portname
    portname="supertux"

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    addPort "${md_id}" "${portname}" "SuperTux" "${md_inst}/bin/supertux2 --userdir ${md_conf_root}/${md_id}/ --fullscreen"
}
