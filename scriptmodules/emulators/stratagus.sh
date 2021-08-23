#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="stratagus"
rp_module_desc="Stratagus - Strategy Game Engine to Play Warcraft I, II & Starcraft"
rp_module_help="Copy your Stratagus games to $romdir/stratagus"
rp_module_licence="GPL2 https://raw.githubusercontent.com/Wargus/stratagus/master/COPYING"
rp_module_repo="git https://github.com/Wargus/stratagus.git :_get_branch_stratagus"
rp_module_section="opt"
rp_module_flags="!mali !kms"

function _get_branch_stratagus() {
    download https://api.github.com/repos/Wargus/stratagus/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_stratagus() {
    local depends=(
        'cmake'
        'libmng'
        'libtheora'
        'lua51'
        'sdl2_image'
        'sdl2_mixer'
        'sqlite'
        'tolua++'
    )
    getDepends "${depends[@]}"
}

function sources_stratagus() {
    gitPullOrClone
}

function build_stratagus() {
    mkdir build
    cd build
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DLUA_INCLUDE_DIR=/usr/include/lua5.1 \
        -DCMAKE_CXX_FLAGS+="-Wno-error -Wno-dev" \
        -DENABLE_STRIP=ON
    make clean
    make
    md_ret_require="$md_build/build/stratagus"
}

function install_stratagus() {
    md_ret_files=(
        'build/stratagus'
        'COPYING'
    )
}

function configure_stratagus() {
    mkRomDir "stratagus"

    addEmulator 0 "$md_id" "stratagus" "$md_inst/stratagus -F -d %ROM%"
    addSystem "stratagus" "Stratagus Strategy Engine" ".wc1 .wc2 .sc .data"
}
