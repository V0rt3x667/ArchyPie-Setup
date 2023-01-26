#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="openjazz"
rp_module_desc="OpenJazz: Open-Source Version of the Classic Jazz Jackrabbit Games"
rp_module_licence="GPL2 https://raw.githubusercontent.com/AlisterT/openjazz/master/COPYING"
rp_module_help="For Registered Version, Replace the Shareware Files by Adding the Full Version Game Files to: ${romdir}/ports/jazz."
rp_module_repo="git https://github.com/AlisterT/openjazz master"
rp_module_section="opt"
rp_module_flags=""

function depends_openjazz() {
    local depends=(
        'sdl_net'
        'sdl12-compat'
    )
    getDepends "${depends[@]}"
}

function sources_openjazz() {
    gitPullOrClone
}

function build_openjazz() {
    make clean
    make PREFIX="${md_inst}" USE_SDL_NET=1
    md_ret_require="${md_build}/OpenJazz"
}

function install_openjazz() {
    md_ret_files=(
        'openjazz.000'
        'OpenJazz'
        'README.md'
    )
}

function _game_data_openjazz() {
    if [[ ! -f "${romdir}/ports/jazz/JAZZ.EXE" ]]; then
        downloadAndExtract "https://image.dosgamesarchive.com/games/jazz.zip" "${romdir}/ports/jazz"
        chown -R "${user}:${user}" "${romdir}/ports/jazz"
    fi
}

function configure_openjazz() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "ports/jazz"
        _game_data_openjazz
    fi

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}"

    addPort "${md_id}" "${md_id}" "Jazz Jackrabbit" "pushd ${md_conf_root}/${md_id}; ${md_inst}/OpenJazz -f DATAPATH ${romdir}/ports/jazz; popd"
}
