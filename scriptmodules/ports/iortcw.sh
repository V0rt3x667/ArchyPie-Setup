#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="iortcw"
rp_module_desc="iortcw: Return to Castle Wolfenstein Port"
rp_module_licence="GPL3 https://raw.githubusercontent.com/iortcw/iortcw/master/LICENCE.md"
rp_module_repo="git https://github.com/iortcw/iortcw master"
rp_module_section="opt"
rp_module_flags="!rpi"

function depends_iortcw() {
    local depends=(
        'freetype2'
        'graphite'
        'harfbuzz'
        'libjpeg-turbo'
        'libogg'
        'openal'
        'opus'
        'opusfile'
        'pcre'
        'perl-rename'
        'sdl2'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_iortcw() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|\".wolf\"|\"ArchyPie/configs/${md_id}\"|g" -i "${md_build}/MP/code/qcommon/q_shared.h"
    sed -e "s|\".wolf\"|\"ArchyPie/configs/${md_id}\"|g" -i "${md_build}/SP/code/qcommon/q_shared.h"
    sed -e "s|\".wolf\"|\"ArchyPie/configs/${md_id}\"|g" -i "${md_build}/MP/code/splines/q_splineshared.h"
    sed -e "s|\".wolf\"|\"ArchyPie/configs/${md_id}\"|g" -i "${md_build}/SP/code/splines/q_splineshared.h"
}

function build_iortcw() {
    local dirs=('MP' 'SP')
    for dir in "${dirs[@]}"; do
        make -C "${dir}" clean
        make -C "${dir}" COPYDIR="${md_inst}" USE_INTERNAL_LIBS=0
    done
    md_ret_require=(
        "${md_build}/MP/build/release-linux-$(_arch_"${md_id}")/iowolfmp.$(_arch_"${md_id}")"
        "${md_build}/SP/build/release-linux-$(_arch_"${md_id}")/iowolfsp.$(_arch_"${md_id}")"
    )
}

function _arch_iortcw() {
    uname -m | sed -e "s|i.86|x86|g" | sed -e "s|^arm.*|arm|g"
}

function install_iortcw() {
    local dirs=('MP' 'SP')
    for dir in "${dirs[@]}"; do
        make -C "${dir}" COPYDIR="${md_inst}" USE_INTERNAL_LIBS=0 copyfiles
    done
}

function _add_games_iortcw() {
    local cmd="$1"
    local dir
    local game
    local portname

    declare -A games=(
        ['main/pak0.pk3']="Return to Castle Wolfenstein (SP)"
        ['main/mp_pak0.pk3']="Return to Castle Wolfenstein (MP)"
    )
    portname="rtcw"

    # Create .sh Files For Each Game Found. Uppercase Filenames Will Be Converted to Lowercase.
    for game in "${!games[@]}"; do
        dir="${romdir}/ports/${portname}"
        if [[ "${md_mode}" == "install" ]]; then
            pushd "${dir}/${game%%/*}" || return
            perl-rename 'y/A-Z/a-z/' [^.-]{*,*/*}
            popd || return
        fi
        if [[ -f "${dir}/${game}" ]]; then
            if [[ "${game##*/}"  == "mp_pak0.pk3" ]]; then
                addPort "${md_id}" "${portname}" "${games[$game]}" "${cmd}" "iowolfmp"
            else
                addPort "${md_id}" "${portname}" "${games[$game]}" "${cmd}" "iowolfsp"
            fi
        fi
    done
}

function configure_iortcw() {
    local portname
    portname="rtcw"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "ports/${portname}"
        mkRomDir "ports/${portname}/main"
    fi

    moveConfigDir "${md_inst}/main" "${romdir}/ports/${portname}/main"
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${portname}/${md_id}"

    local launcher=("${md_inst}/%ROM%.$(_arch_"${md_id}")")
    isPlatform "mesa" && launcher+=("+set cl_renderer opengl1")
    isPlatform "kms" && launcher+=("+set r_mode -1" "+set r_customwidth %XRES%" "+set r_customheight %YRES%" "+set r_swapInterval 1")
    isPlatform "x11" || isPlatform "wayland" && launcher+=("+set r_mode -2" "+set r_fullscreen 1")

    _add_games_iortcw "${launcher[*]}"
}
