#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="stratagus"
rp_module_desc="Stratagus: Warcraft I, II & Starcraft Game Engine"
rp_module_help="ROM Extensions: .data .sc .wc1 .wc2\n\nCopy Stratagus Games To: ${romdir}/stratagus"
rp_module_licence="GPL2 https://raw.githubusercontent.com/Wargus/stratagus/master/COPYING"
rp_module_repo="git https://github.com/Wargus/stratagus :_get_branch_stratagus"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_stratagus() {
    download "https://api.github.com/repos/Wargus/${md_id}/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_stratagus() {
    local depends=(
        'cmake'
        'glu'
        'libmng'
        'libtheora'
        'ninja'
        'sdl2_image'
        'sdl2_mixer'
        'sdl2'
        'sqlite'
        'tolua++'
    )
    getDepends "${depends[@]}"
}

function sources_stratagus() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|\"/.stratagus/\"|\"/ArchyPie/configs/${md_id}/\"|g" -i "${md_build}/gameheaders/stratagus-game-launcher.h"
}

function build_stratagus() {
    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DLUA_INCLUDE_DIR="/usr/include/lua5.1" \
        -DENABLE_STRIP="ON" \
        -DWITH_STACKTRACE="OFF" \
        -DGAMEDIR="${md_inst}/bin" \
        -DSBINDIR="${md_inst}/bin" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/${md_id}"
}

function install_stratagus() {
    ninja -C build install/strip
    md_ret_require="${md_inst}/bin/${md_id}"
}

function configure_stratagus() {
    mkRomDir "stratagus"

    addEmulator 1 "${md_id}" "${md_id}" "${md_inst}/bin/"${md_id}" -F -d %ROM%"

    addSystem "${md_id}"
}
