#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="cgenius"
rp_module_desc="Commander Genius - Modern Interpreter for the Commander Keen Games (Vorticon and Galaxy Games)"
rp_module_licence="GPL2 https://raw.githubusercontent.com/gerstrong/Commander-Genius/master/COPYRIGHT"
rp_module_repo="git https://gitlab.com/Dringgstein/Commander-Genius.git :_get_branch_cgenius"
rp_module_section="exp"

function _get_branch_cgenius() {
    download https://gitlab.com/api/v4/projects/Dringgstein%2FCommander-Genius/releases - | grep -m 1 tag_name | cut -d\" -f8
}

function depends_cgenius() {
    local depends=(
        'cmake'
        'sdl2_image' 
        'sdl2_mixer'
        'sdl2_ttf'
    )
    getDepends "${depends[@]}"
}

function sources_cgenius() {
    gitPullOrClone
}

function build_cgenius() {
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DAPPDIR="$md_inst" \
        -DNOTYPESAVE=on
    ninja -C build
    md_ret_require="$md_build/build/src/CGeniusExe"
}

function install_cgenius() {
    ninja -C build install/strip
}

function configure_cgenius() {
    addPort "$md_id" "cgenius" "Commander Genius" "$md_inst/CGeniusExe dir=%ROM%"

    mkRomDir "ports/$md_id"

    moveConfigDir "$home/.CommanderGenius"  "$md_conf_root/$md_id"
    moveConfigDir "$md_conf_root/$md_id/games"  "$romdir/ports/$md_id"
}
