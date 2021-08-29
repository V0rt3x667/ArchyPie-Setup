#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="openjazz"
rp_module_desc="OpenJazz - Open-Source Version of the Classic Jazz Jackrabbit Games"
rp_module_licence="GPL2 https://raw.githubusercontent.com/AlisterT/openjazz/master/COPYING"
rp_module_help="For registered version, replace the shareware files by adding your full version game files to $romdir/ports/jazz."
rp_module_repo="git https://github.com/AlisterT/openjazz.git master"
rp_module_section="opt"
rp_module_flags=""

function depends_openjazz() {
    getDepends sdl sdl_net
}

function sources_openjazz() {
    gitPullOrClone
}

function build_openjazz() {
    make clean
    make PREFIX="$md_inst" USE_SDL_NET=1
    md_ret_require="$md_build/OpenJazz"
}

function install_openjazz() {
    md_ret_files=(
        'OpenJazz'
        'openjazz.000'
        'README.md'
    )
}

function _game_data_openjazz() {
    if [[ ! -f "$romdir/ports/jazz/JAZZ.EXE" ]]; then
        downloadAndExtract "https://image.dosgamesarchive.com/games/jazz.zip" "$romdir/ports/jazz"
        chown -R "$user:$user" "$romdir/ports/jazz"
    fi
}

function configure_openjazz() {
    addPort "$md_id" "$md_id" "Jazz Jackrabbit" "$md_inst/bin/OpenJazz -f DATAPATH $romdir/ports/jazz"

    mkRomDir "ports/jazz"

    moveConfigDir "$home/.openjazz" "$md_conf_root/openjazz"

#  moveConfigFile "$home/openjazz.cfg" "$md_conf_root/openjazz/openjazz.cfg"

    [[ "$md_mode" == "install" ]] && _game_data_openjazz
}
