#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="ioquake3"
rp_module_desc="ioquake3: Quake 3 Arena Port"
rp_module_help="ROM Extensions: .pk3\n\nCopy Quake III Arena Files To: ${romdir}/ports/quake3/baseq3\n\nCopy Quake III Team Fortress Files To: ${romdir}/ports/quake3/missionpack"
rp_module_licence="GPL2 https://github.com/ioquake/ioq3/blob/master/COPYING.txt"
rp_module_repo="git https://github.com/ioquake/ioq3 main"
rp_module_section="opt"
rp_module_flags=""

function depends_ioquake3() {
    local depends=(
        'curl'
        'libogg'
        'libvorbis'
        'mesa'
        'openal'
        'opus'
        'opusfile'
        'sdl2'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_ioquake3() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|\".q3a\"|\"ArchyPie/configs/${md_id}\"|g" -i "${md_build}/code/qcommon/q_shared.h"
}

function build_ioquake3() {
    make clean
    make COPYDIR="${md_inst}" USE_INTERNAL_LIBS=0 DEFAULT_BASEDIR="${romdir}/ports/quake3"
    md_ret_require="${md_build}/build/release-linux-$(_arch_${md_id})/${md_id}.$(_arch_${md_id})"
}

function _arch_ioquake3() {
    uname -m | sed -e "s|i.86|x86|" | sed -e "s|^arm.*|arm|" | sed -e "s|aarch64|arm64|"
}

function install_ioquake3() {
    make COPYDIR="${md_inst}" USE_INTERNAL_LIBS=0 DEFAULT_BASEDIR="${romdir}/ports/quake3" copyfiles
}

function _add_games_ioquake3() {
    local cmd="${1}"
    local dir
    local game
    local portname

    declare -A games=(
        ['baseq3/pak0.pk3']="Quake III Arena"
        ['missionpack/pak0.pk3']="Quake III: Team Arena"
    )

    for game in "${!games[@]}"; do
        portname="quake3"
        dir="${romdir}/ports/${portname}/${game%%/*}"
        # Convert Uppercase Filenames To Lowercase
        [[ "${md_mode}" == "install" ]] && changeFileCase "${dir}"
        # Create Launch Scripts For Each Game Found
        if [[ -f "${dir}/${game##*/}" ]]; then
            addPort "${md_id}" "${portname}" "${games[${game}]}" "${cmd}" "${game%%/*}"
        fi
    done
}

function configure_ioquake3() {
    local portname
    portname="quake3"

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${portname}/${md_id}/"

    if [[ "${md_mode}" == "install" ]]; then
        local dirs=(
            'baseq3'
            'missionpack'
        )

        mkRomDir "ports/${portname}"

        for dir in "${dirs[@]}"; do
            mkRomDir "ports/${portname}/${dir}"
        done

        _game_data_quake3
    fi

    local launcher=("${md_inst}/${md_id}.$(_arch_${md_id}) +set fs_game %ROM%")

    isPlatform "mesa" && launcher+=("+set cl_renderer opengl1")
    isPlatform "kms" && launcher+=("+set r_mode -1" "+set r_customwidth %XRES%" "+set r_customheight %YRES%" "+set r_swapInterval 1")
    isPlatform "x11" && launcher+=("+set r_mode -2" "+set cl_renderer opengl2" "+set r_fullscreen 1")

    _add_games_ioquake3 "${launcher[*]}"
}
