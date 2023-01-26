#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="uhexen2"
rp_module_desc="Hammer of Thyrion (uHexen2): Hexen II Source Port"
rp_module_licence="GPL2 https://raw.githubusercontent.com/sezero/uhexen2/master/docs/COPYING"
rp_module_help="Copy pak0.pak & strings.txt To: ${romdir}/ports/hexen2/data1/ & pak1.pak To: ${romdir}/ports/hexen2/portals/"
rp_module_repo="git https://github.com/sezero/uhexen2 master"
rp_module_section="opt"
rp_module_flags=""

function depends_uhexen2() {
    local depends=(
        'alsa-lib'
        'flac'
        'libglvnd'
        'libmad'
        'libogg'
        'libvorbis'
        'sdl12-compat'
        'sdl2'
    )
    isPlatform "x86" && isPlatform "32bit" && depends+=('yasm')
    getDepends "${depends[@]}"
}

function sources_uhexen2() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|#define[[:blank:]]*SYS_USERDIR_UNIX[[:blank:]]*\".hexen2\"|#define SYS_USERDIR_UNIX \"ArchyPie/configs/${md_id}\"|g" -i "${md_build}/engine/h2shared/userdir.h"
    sed -e "s|#define[[:blank:]]*SYS_USERDIR_UNIX[[:blank:]]*\".hexen2demo\"|#define SYS_USERDIR_UNIX \"ArchyPie/configs/${md_id}/demo\"|g" -i "${md_build}/engine/h2shared/userdir.h"
}

function build_uhexen2() {
    local portname
    portname="hexen2"

    # Build Hexen Game Engine
    cd "${md_build}/engine/${portname}" || return
    ./build_all.sh
    # Build HexenWorld
    cd "${md_build}/engine/hexenworld" || return
    ./build.sh
    # Build Hexen Utilities
    cd "${md_build}" || return
    make -C hw_utils/hwmaster
    make -C h2patch
    make -C utils/hcc
    # Build Game Code Files
    cd "${md_build}/gamecode" || return
    "${md_build}/utils/hcc/hcc" -src hc/h2 -os
    "${md_build}/utils/hcc/hcc" -src hc/h2 -os -name progs2.src
    "${md_build}/utils/hcc/hcc" -src hc/portals -os -oi -on
    "${md_build}/utils/hcc/hcc" -src hc/hw -os -oi -on
    "${md_build}/utils/hcc/hcc" -src hc/siege -os -oi -on

    md_ret_require="${md_build}/engine/${portname}/${portname}"
}

function install_uhexen2() {
    md_ret_files=(
        'docs/'
        'engine/hexen2/server/h2ded'
        'engine/hexenworld/client/glhwcl'
        'engine/hexenworld/client/hwcl'
        'engine/hexenworld/server/hwsv'
        'gamecode/hc/h2'
        'gamecode/hc/hw'
        'gamecode/hc/portals'
        'gamecode/hc/portals'
        'gamecode/mapfixes/data1'
        'gamecode/mapfixes/portals'
        'gamecode/patch111/patchdat'
        'h2patch/h2patch'
        'scripts/'
    )
    if isPlatform "gl" || isPlatform "mesa"; then
        md_ret_files+=('engine/hexen2/glhexen2')
    else
        md_ret_files+=('engine/hexen2/hexen2')
    fi
}

function _game_data_uhexen2() {
    local portname
    portname="hexen2"

    if [[ ! -f "${romdir}/ports/${portname}/data1/pak0.pak" ]]; then
        downloadAndExtract "http://sourceforge.net/project/downloading.php?group_id=124987&filename=hexen2demo_nov1997-linux-x86_64.tgz" "${romdir}/ports/${portname}" --strip-components 1 "hexen2demo_nov1997/data1"
        chown -R "${user}:${user}" "${romdir}/ports/${portname}/data1"
    fi
}

function _add_games_uhexen2() {
    local cmd="$1"
    local dir
    local game
    local portname
    declare -A games=(
        ['data1/pak0.pak']="Hexen II"
        ['portals/pak3.pak']="Hexen II: Portal of Praevus"
    )

    # Create .sh Files For Each Game Found. Uppercase Filenames Will Be Converted to Lowercase.
    for game in "${!games[@]}"; do
        portname="hexen2"
        dir="${romdir}/ports/${portname}/${game%/*}"
        if [[ "${md_mode}" == "install" ]]; then
            pushd "${dir}" || return
            perl-rename 'y/A-Z/a-z/' [^.-]{*,*/*}
            popd || return
        fi
        if [[ -f "${dir}/${game##*/}" ]]; then
            if [[ "${game##*/}" == "pak3.pak" ]]; then
                addPort "${md_id}" "${portname}" "${games[$game]}" "${cmd} -portals" "${game%%/*}"
            elif [[ "${game##*/}" == "pak0.pak" ]]; then
                addPort "${md_id}" "${portname}" "${games[$game]}" "${cmd}" "${game%%/*}"
            fi
        fi
    done
}

function configure_uhexen2() {
    local portname
    portname="hexen2"

    if [[ "${md_mode}" == "install" ]]; then
        local dirs=(
            'data1'
            'portals'
        )
        mkRomDir "ports/${portname}"
        for dir in "${dirs[@]}"; do
            mkRomDir "ports/${portname}/${dir}"
        done
        _game_data_uhexen2
    fi

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${portname}/${md_id}/"

    local binary
    local params=("-basedir ${romdir}/ports/${portname}" '-f' '-vsync')

    if isPlatform "gl" || isPlatform "mesa"; then
        binary="${md_inst}/glhexen2"
    else
        binary="${md_inst}/hexen2"
    fi

    _add_games_uhexen2 "${binary} ${params[*]}"
}
