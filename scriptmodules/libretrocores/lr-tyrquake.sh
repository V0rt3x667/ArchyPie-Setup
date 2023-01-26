#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-tyrquake"
rp_module_desc="Quake Libretro Core"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/tyrquake/master/LICENSE.txt"
rp_module_repo="git https://github.com/libretro/tyrquake master"
rp_module_section="opt"

function depends_lr-tyrquake() {
    local depends=('perl-rename')
    getDepends "${depends[@]}"
}

function sources_lr-tyrquake() {
    gitPullOrClone
}

function build_lr-tyrquake() {
    make clean
    make
    md_ret_require="${md_build}/tyrquake_libretro.so"
}

function install_lr-tyrquake() {
    md_ret_files=(
        'LICENSE.txt'
        'readme-id.txt'
        'readme.txt'
        'tyrquake_libretro.so'
    )
}

function _game_data_lr-tyrquake() {
    local portname
    portname="quake"

    if [[ ! -f "${romdir}/ports/${portname}/id1/pak0.pak" ]]; then
        local temp
        temp="$(mktemp -d)"

        local depends=('lhasa')
        getDepends "${depends[@]}"

        downloadAndExtract "${__archive_url}/quake106.zip" "${temp}"
        pushd "${temp}" || exit
        lha ef resource.1
        cp -rf id1 "${romdir}/ports/${portname}/"
        popd || exit
        rm -rf "${temp}"
        chown -R "${user}:${user}" "${romdir}/ports/${portname}"
    fi
}

function _add_games_lr-tyrquake() {
    local cmd="$1"
    local dir
    local game
    local portname
    declare -A games=(
        ['id1/pak0.pak']="Quake"
        ['hipnotic/pak0.pak']="Quake: Mission Pack 1: Scourge of Armagon"
        ['rogue/pak0.pak']="Quake: Mission Pack 2: Dissolution of Eternity"
        ['dopa/pak0.pak']="Quake: Episode 5: Dimensions of the Past"
    )

    # Create .sh Files For Each Game Found. Uppercase Filenames Will Be Converted to Lowercase.
    for game in "${!games[@]}"; do
        portname="quake"
        dir="${romdir}/ports/${portname}/${game%/*}"
        if [[ "${md_mode}" == "install" ]]; then
            pushd "${dir}" || return
            perl-rename 'y/A-Z/a-z/' [^.-]{*,*/*}
            popd || return
        fi
        if [[ -f "${dir}/${game##*/}" ]]; then
            if [[ "${cmd}" =~ "darkplaces-sdl-gles" ]]; then
                addPort "${md_id}-gles" "${portname}" "${games[$game]}" "${cmd}" "${game##*/}"
            elif [[ "${md_id}" == "lr-tyrquake" ]]; then
                addPort "${md_id}" "${portname}" "${games[$game]}" "${cmd}" "${dir}/${game##*/}"
            else
                addPort "${md_id}" "${portname}" "${games[$game]}" "${cmd}" "${game##*/}"
            fi
        fi
    done
}

function configure_lr-tyrquake() {
    local portname
    portname="quake"

    if [[ "$md_mode" == "install" ]]; then
        local dirs=(
            'dopa'
            'hipnotic'
            'id1'
            'rogue'
        )
        mkRomDir "ports/${portname}"
        for dir in "${dirs[@]}"; do
            mkRomDir "ports/${portname}/${dir}"
        done
        _game_data_lr-tyrquake
    fi

    setConfigRoot "ports"

    defaultRAConfig "${portname}"

    _add_games_lr-tyrquake "${md_inst}/tyrquake_libretro.so"
}
