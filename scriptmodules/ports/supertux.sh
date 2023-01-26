#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="supertux"
rp_module_desc="SuperTux: Classic 2D Jump'n'Run Sidescroller Game"
rp_module_licence="GPL3 https://raw.githubusercontent.com/SuperTux/supertux/master/LICENSE.txt"
rp_module_repo="git https://github.com/SuperTux/supertux :_get_branch_supertux"
rp_module_section="opt"
rp_module_flags="!mali"

function _get_branch_supertux() {
    download "https://api.github.com/repos/${md_id}/${md_id}/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_supertux() {
    local depends=(
        'boost-libs'
        'boost'
        'cmake'
        'curl'
        'freetype2'
        'glew'
        'libraqm'
        'libvorbis'
        'mesa'
        'ninja'
        'openal'
        'optipng'
        'physfs'
        'sdl2_image'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_supertux() {
    gitPullOrClone

    # Fix Build On GCC12
    sed "1i#include <memory>" -i "${md_build}/external/partio_zip/zip_manager.cpp"
}

function build_supertux() {
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DINSTALL_SUBDIR_BIN="bin" \
        -DUSE_SYSTEM_PHYSFS="ON" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/supertux2"
}

function install_supertux() {
    ninja -C build install/strip
}

function configure_supertux() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    addPort "${md_id}" "${md_id}" "SuperTux" "${md_inst}/bin/supertux2 --userdir ${md_conf_root}/${md_id}/ --fullscreen"
}
