#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="ioquake3"
rp_module_desc="ioquake3: Quake 3 Arena Port"
rp_module_licence="GPL2 https://github.com/ioquake/ioq3/blob/master/COPYING.txt"
rp_module_repo="git https://github.com/ioquake/ioq3 main"
rp_module_section="opt"
rp_module_flags="!rpi"

function depends_ioquake3() {
    local depends=(
        'mesa'
        'perl-rename'
        'sdl2'
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
    make COPYDIR="${md_inst}" USE_INTERNAL_LIBS=0
    md_ret_require="${md_build}/build/release-linux-$(_arch_${md_id})/${md_id}.$(_arch_${md_id})"
}

function _arch_ioquake3() {
    uname -m | sed -e "s|i.86|x86|" | sed -e "s|^arm.*|arm|"
}

function install_ioquake3() {
    make COPYDIR="${md_inst}" USE_INTERNAL_LIBS=0 copyfiles
}

function _add_games_ioquake3() {
    local cmd="$1"
    local dir
    local game
    local portname

    declare -A games=(
        ['baseq3/pak0.pk3']="Quake III Arena"
        ['demoq3/pak0.pk3']="Quake III Arena (Demo)"
        ['missionpack/pak0.pk3']="Quake III: Team Arena"
    )
    portname="quake3"

    # Create .sh Files For Each Game Found. Uppercase Filenames Will Be Converted to Lowercase.
    for game in "${!games[@]}"; do
        dir="${romdir}/ports/${portname}"
        if [[ "${md_mode}" == "install" ]]; then
            pushd "${dir}/${game%%/*}" || return
            perl-rename 'y/A-Z/a-z/' [^.-]{*,*/*}
            popd || return
        fi
        if [[ -f "${dir}/${game}" ]]; then
            addPort "${md_id}" "${portname}" "${games[$game]}" "${cmd}" "${game%%/*}"
        fi
    done
}

function configure_ioquake3() {
    local portname
    portname="quake3"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "ports/${portname}"
        mkRomDir "ports/${portname}/baseq3"
        mkRomDir "ports/${portname}/demoq3"
        mkRomDir "ports/${portname}/missionpack"

        _game_data_quake3
    fi

    moveConfigDir "${md_inst}/baseq3" "${romdir}/ports/${portname}/baseq3"
    moveConfigDir "${md_inst}/missionpack" "${romdir}/ports/${portname}/missionpack"
    moveConfigDir "${md_inst}/demoq3" "${romdir}/ports/${portname}/demoq3"
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${portname}/${md_id}/"

    local launcher=("${md_inst}/${md_id}.$(_arch_${md_id}) +set fs_game %ROM%")
    isPlatform "mesa" && launcher+=("+set cl_renderer opengl1")
    isPlatform "kms" && launcher+=("+set r_mode -1" "+set r_customwidth %XRES%" "+set r_customheight %YRES%" "+set r_swapInterval 1")
    isPlatform "x11" || isPlatform "wayland" && launcher+=("+set r_mode -2" "+set cl_renderer opengl2" "+set r_fullscreen 1")

    _add_games_ioquake3 "${launcher[*]}"
}
