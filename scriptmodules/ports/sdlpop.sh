#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="sdlpop"
rp_module_desc="SDLPoP - Open-Source Port of Prince of Persia"
rp_module_licence="GPL3 https://raw.githubusercontent.com/NagyD/SDLPoP/master/COPYING"
rp_module_repo="git https://github.com/NagyD/SDLPoP.git master"
rp_module_section="opt"

function depends_sdlpop() {
    depends=(
        'cmake'
        'ninja'
        'sdl2_image'
        'sdl2_mixer'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_sdlpop() {
    gitPullOrClone
}

function build_sdlpop() {
    cmake . \
        -Ssrc \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -Wno-dev
    ninja clean
    ninja
    md_ret_require="$md_build/prince"
}

function install_sdlpop() {
    md_ret_files=(
        'data'
        'doc'
        'prince'
        'SDLPoP.ini'
    )
}

function configure_sdlpop() {
    addPort "$md_id" "sdlpop" "Prince of Persia" "$md_inst/prince full"

    [[ "$md_mode" == "remove" ]] && return

    moveConfigFile "$md_inst/SDLPoP.ini" "$md_conf_root/$md_id/SDLPoP.ini"
    moveConfigFile "$md_inst/PRINCE.SAV" "$md_conf_root/$md_id/PRINCE.SAV"
    moveConfigFile "$md_inst/QUICKSAVE.SAV" "$md_conf_root/$md_id/QUICKSAVE.SAV"
    moveConfigFile "$md_inst/SDLPoP.cfg" "$md_conf_root/$md_id/SDLPoP.cfg"

    chown -R "$user:$user" "$md_conf_root/$md_id"
}
