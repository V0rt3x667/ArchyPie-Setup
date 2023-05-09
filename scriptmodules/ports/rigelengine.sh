#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="rigelengine"
rp_module_desc="RigelEngine: Duke Nukem II Source Port"
rp_module_help="Copy (NUKEM2.CMP, NUKEM2.F1, NUKEM2.F2, NUKEM2.F3, NUKEM2.F4, NUKEM2.F5) To: ${romdir}/duke2"
rp_module_licence="GPL2 https://raw.githubusercontent.com/lethal-guitar/RigelEngine/master/LICENSE.md"
rp_module_repo="git https://github.com/lethal-guitar/RigelEngine :_get_branch_rigelengine"
rp_module_section="exp"
rp_module_flags=""

function _get_branch_rigelengine() {
    download "https://api.github.com/repos/lethal-guitar/RigelEngine/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_rigelengine() {
    local depends=(
        'cmake'
        'ninja'
        'sdl2_mixer'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_rigelengine() {
    gitPullOrClone

    # Add Missing Include
    sed -i "25i#include <cstdint>" "${md_build}/src/assets/user_profile_import.hpp"
}

function build_rigelengine() {
    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DWARNINGS_AS_ERRORS="OFF" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/src/RigelEngine"
}

function install_rigelengine() {
    md_ret_files=('build/src/RigelEngine')
}

function configure_rigelengine() {
    mkRomDir "ports/duke2"

    addPort "${md_id}" "${md_id}" "Duke Nukem II" "${md_inst}/RigelEngine ${romdir}/ports/duke2"
}
