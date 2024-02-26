#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="srb2"
rp_module_desc="Sonic Robo Blast 2: 3D Sonic the Hedgehog Fangame"
rp_module_licence="GPL2 https://raw.githubusercontent.com/STJr/SRB2/master/LICENSE"
rp_module_repo="git https://github.com/STJr/SRB2 :_get_branch_srb2"
rp_module_section="exp"

function _get_branch_srb2() {
    download "https://api.github.com/repos/STJr/srb2/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_srb2() {
    local depends=(
        'clang'
        'cmake'
        'curl'
        'libgme'
        'libopenmpt'
        'libpng'
        'libupnp'
        'lld'
        'ninja'
        'sdl2_mixer'
        'sdl2'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_srb2() {
    local branch
    local ver
    branch="$(_get_branch_srb2)"
    ver="${branch//./}"

    gitPullOrClone

    # Download Assets
    downloadAndExtract "https://github.com/STJr/${md_id}/releases/download/${branch}/${md_id}-v${ver##*_}-Full.zip" "${md_build}/assets/installer"

    # Set Default Config Path(s)
    sed -e "s|DEFAULTDIR \".srb2\"|DEFAULTDIR \"${md_id}\"|g" -i "${md_build}/src/doomdef.h"
}

function build_srb2() {
    local branch
    branch="$(_get_branch_srb2)"

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
        -DBUILD_TESTING="OFF" \
        -DSRB2_CONFIG_ENABLE_TESTS="OFF" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/bin/lsdlsrb2_${branch}"
}

function install_srb2() {
    local branch
    branch="$(_get_branch_srb2)"

    md_ret_files=(
        'assets/installer/music.dta'
        'assets/installer/patch.pk3'
        'assets/installer/player.dta'
        'assets/installer/srb2.pk3'
        'assets/installer/zones.pk3'
        'assets/README.txt'
    )

    # Rename Binary To 'srb2'
    cp "build/bin/lsdlsrb2_${branch}" "${md_inst}/srb2"
}

function configure_srb2() {
    local portname
    portname="srb2"

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    local launcher_prefix="SRB2WADDIR=${md_inst}"
    local params=()

    if isPlatform "x11"; then
        params+=("-opengl")
    fi

    addPort "${md_id}" "${portname}" "Sonic Robo Blast 2" "${launcher_prefix} ${md_inst}/${md_id} -home ${md_conf_root} ${params[*]}"
}
