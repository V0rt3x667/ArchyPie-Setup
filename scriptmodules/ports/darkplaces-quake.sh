#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="darkplaces-quake"
rp_module_desc="DarkPlaces: Quake Engine"
rp_module_licence="GPL2 https://raw.githubusercontent.com/xonotic/darkplaces/master/COPYING"
rp_module_repo="git https://github.com/xonotic/darkplaces master"
rp_module_section="opt"
rp_module_flags=""

function depends_darkplaces-quake() {
    local depends=(
        'curl'
        'freetype2'
        'libjpeg-turbo'
        'libogg'
        'libpng'
        'libtheora'
        'libvorbis'
        'sdl2'
        'zlib'
    )
    isPlatform "mesa" && depends+=('mesa')
    getDepends "${depends[@]}"
}

function sources_darkplaces-quake() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|homedir, gameuserdirname|homedir, \"/ArchyPie/configs/${md_id}\"|g" -i "${md_build}/fs.c"
}

function build_darkplaces-quake() {
    make clean
    make sdl-release

    md_ret_require+=("${md_build}/darkplaces-sdl")
}

function install_darkplaces-quake() {
    md_ret_files=(
        'darkplaces-sdl'
        'darkplaces.txt'
    )
}

function configure_darkplaces-quake() {
    local portname
    portname="quake"

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${portname}/${md_id}/"

    if [[ "${md_mode}" == "install" ]]; then
        local dirs=(
            'dopa'
            'hipnotic'
            'id1'
            'quoth'
            'rogue'
        )
        mkRomDir "ports/${portname}"
        for dir in "${dirs[@]}"; do
            mkRomDir "ports/${portname}/${dir}"
        done
        _game_data_lr-tyrquake
    fi

    local params=("-basedir ${romdir}/ports/${portname}" "-game %QUAKEDIR%")

    isPlatform "kms" && params+=("+vid_vsync 1")

    _add_games_lr-tyrquake "${md_inst}/darkplaces-sdl ${params[*]}"
}
