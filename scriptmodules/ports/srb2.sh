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
    download "https://api.github.com/repos/STJr/${md_id}/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_srb2() {
    local depends=(
        'cmake'
        'curl'
        'libgme'
        'libopenmpt'
        'libpng'
        'ninja'
        'sdl2_mixer'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_srb2() {
    local branch
    local ver
    branch="$(_get_branch_srb2)"
    ver="${branch//./}"

    gitPullOrClone
    downloadAndExtract "https://github.com/STJr/${md_id}/releases/download/${branch}/${md_id}-v${ver##*_}-Full.zip" "${md_build}/assets/installer"

    # Set Default Config Path(s)
    sed -e "s|DEFAULTDIR \".srb2\"|DEFAULTDIR \"${md_id}\"|g" -i "${md_build}/src/doomdef.h"

    # Fix Bug #500 "https://github.com/STJr/SRB2/issues/500"
    sed -e "s|set(CMAKE_C_FLAGS \${CMAKE_C_FLAGS} -Wno-trigraphs)|set(CMAKE_C_FLAGS \"\${CMAKE_C_FLAGS} -Wno-trigraphs\")|g" -i "${md_build}/src/CMakeLists.txt"
}

function build_srb2() {
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DSRB2_ASSET_HASHED="srb2.pk3;player.dta;music.dta;zones.pk3" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/bin/lsdlsrb2"
}

function install_srb2() {
    # Copy And Dereference, So We Get A srb2 Binary Rather Than A Symlink To lsdlsrb2
    cp -L 'build/bin/lsdlsrb2' "${md_inst}/${md_id}"

    md_ret_files=(
        'assets/installer/music.dta'
        'assets/installer/player.dta'
        'assets/installer/srb2.pk3'
        'assets/installer/zones.pk3'
        'assets/LICENSE.txt'
        'assets/README.txt'
    )
}

function configure_srb2() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    if isPlatform "x11" || isPlatform "wayland"; then
        addPort "${md_id}" "${md_id}" "Sonic Robo Blast 2" "${md_inst}/${md_id} -home ${md_conf_root} -opengl"
    else
        addPort "${md_id}" "${md_id}" "Sonic Robo Blast 2" "${md_inst}/${md_id} -home ${md_conf_root}"
    fi
}
