#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="rigelengine"
rp_module_desc="RigelEngine: Duke Nukem II Source Port"
rp_module_help="Copy NUKEM2.CMP, NUKEM2.F1, NUKEM2.F2, NUKEM2.F3, NUKEM2.F4, NUKEM2.F5 To: ${romdir}/duke2"
rp_module_licence="GPL2 https://raw.githubusercontent.com/lethal-guitar/RigelEngine/master/LICENSE.md"
rp_module_repo="git https://github.com/lethal-guitar/RigelEngine :_get_branch_rigelengine"
rp_module_section="exp"
rp_module_flags=""

function _get_branch_rigelengine() {
    download "https://api.github.com/repos/lethal-guitar/RigelEngine/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_rigelengine() {
    local depends=(
        'clang'
        'cmake'
        'entityx'
        'glad'
        'glm'
        'lld'
        'ninja'
        'nlohmann-json'
        'python-loguru'
        'sdl2_mixer'
        'sdl2'
        'speex'
        'stb'
    )
    getDepends "${depends[@]}"
}

function sources_rigelengine() {
    gitPullOrClone

    # Add Missing Include
    sed -i "25i#include <cstdint>" "${md_build}/src/assets/user_profile_import.hpp"
}

function build_rigelengine() {
    isPlatform "arm" && params+=('-DUSE_GL_ES=ON')

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
        "${params[@]}" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/src/RigelEngine"
}

function install_rigelengine() {
    ninja -C build install/strip
}

function configure_rigelengine() {
    mkRomDir "ports/duke2"

    addPort "${md_id}" "${md_id}" "Duke Nukem II" "${md_inst}/bin/RigelEngine ${romdir}/ports/duke2"
}
