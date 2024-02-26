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
    download "https://api.github.com/repos/Wargus/stratagus/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_stratagus() {
    local depends=(
        'bzip2'
        'clang'
        'cmake'
        'glu'
        'libmng'
        'libogg'
        'libtheora'
        'libvorbis'
        'lld'
        'lua51'
        'ninja'
        'openmp'
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
    sed -e "s|userDirectory += \".stratagus\";|userDirectory += \"/ArchyPie/configs/${md_id}\";|g" -i "${md_build}/src/stratagus/parameters.cpp"
}

function build_stratagus() {
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
        -DGAMEDIR="${md_inst}/bin" \
        -DLUA_INCLUDE_DIR="/usr/include/lua5.1" \
        -DWITH_STACKTRACE="OFF" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/${md_id}"
}

function install_stratagus() {
    ninja -C build install/strip
}

function configure_stratagus() {
    setConfigRoot ""

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    [[ "${md_mode}" == "install" ]] && mkRomDir "${md_id}"

    addEmulator 1 "${md_id}" "${md_id}" "${md_inst}/bin/"${md_id}" -F -d %ROM%"

    addSystem "${md_id}"
}
