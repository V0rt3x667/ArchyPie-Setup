#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="srb2kart"
rp_module_desc="Sonic Robo Blast 2 Kart: Kart Racing Mod Based On Sonic Robo Blast 2"
rp_module_licence="GPL2 https://raw.githubusercontent.com/STJr/Kart-Public/master/LICENSE"
rp_module_repo="git https://github.com/STJr/Kart-Public :_get_branch_srb2kart"
rp_module_section="opt"

function _get_branch_srb2kart() {
    download "https://api.github.com/repos/STJr/Kart-Public/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_srb2kart() {
    local depends=(
        'clang'
        'cmake'
        'libgme'
        'libpng'
        'lld'
        'ninja'
        'sdl2_mixer'
        'sdl2'
        'zlib'
    )

    getDepends "${depends[@]}"
}

function sources_srb2kart() {
    local ver
    ver="$(_get_branch_srb2kart)"

    gitPullOrClone

    # Download Assets
    downloadAndExtract "https://github.com/STJr/Kart-Public/releases/download/${ver}/AssetsLinuxOnly.zip" "${md_build}/assets/installer"

    # Set Default Config Path(s)
    sed -e "s|DEFAULTDIR \".srb2kart\"|DEFAULTDIR \"${md_id}\"|g" -i "${md_build}/src/doomdef.h"
}

function build_srb2kart() {
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
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/bin/${md_id}"
}

function install_srb2kart() {
    ninja -C build install/strip
}

function configure_srb2kart() {
    local portname
    portname="srb2kart"

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    local launcher_prefix="SRB2WADDIR=${md_inst}"
    local params=()

    if isPlatform "x11"; then
        params+=("-opengl")
    fi

    addPort "${md_id}" "${portname}" "Sonic Robo Blast 2 Kart" "${launcher_prefix} ${md_inst}/${md_id} -home ${md_conf_root} ${params[*]}"
}
