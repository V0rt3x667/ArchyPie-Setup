#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="srb2"
rp_module_desc="Sonic Robo Blast 2 - 3D Sonic the Hedgehog Fangame"
rp_module_licence="GPL2 https://raw.githubusercontent.com/STJr/SRB2/master/LICENSE"
rp_module_repo="git https://github.com/STJr/SRB2.git :_get_branch_srb2"
rp_module_section="exp"

function _get_branch_srb2() {
    download https://api.github.com/repos/STJr/SRB2/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
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
    downloadAndExtract "https://github.com/STJr/SRB2/releases/download/$ver/SRB2-v${ver##*_}-Full.zip" "$md_build/assets/installer"
}

function build_srb2() {
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DSRB2_ASSET_HASHED="srb2.pk3;player.dta;music.dta;zones.pk3" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="$md_build/build/bin/lsdlsrb2"
}

function install_srb2() {
    # copy and dereference, so we get a srb2 binary rather than a symlink to lsdlsrb2-version
    cp -L 'build/bin/lsdlsrb2' "$md_inst/srb2"

    md_ret_files=(
        'assets/installer/music.dta'
        'assets/installer/player.dta'
        'assets/installer/zones.pk3'
        'assets/installer/srb2.pk3'
        'assets/README.txt'
        'assets/LICENSE.txt'
    )
}

function configure_srb2() {
    addPort "$md_id" "srb2" "Sonic Robo Blast 2" "$md_inst/srb2"

    moveConfigDir "$home/.srb2"  "$md_conf_root/$md_id"
}
