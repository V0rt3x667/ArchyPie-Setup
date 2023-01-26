#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="yquake2"
rp_module_desc="Yamagi Quake II: Quake II Client Including Ground Zero, The Reckoning & Capture The Flag"
rp_module_licence="GPL2 https://raw.githubusercontent.com/yquake2/yquake2/master/LICENSE"
rp_module_repo="git https://github.com/yquake2/yquake2 :_get_branch_yquake2"
rp_module_section="exp"
rp_module_flags=""

function _get_branch_yquake2() {
    download "https://api.github.com/repos/yquake2/yquake2/tags" - | grep -m 1 name | cut -d\" -f4
}

function depends_yquake2() {
    local depends=(
        'glu'
        'libglvnd'
        'libogg'
        'libvorbis'
        'openal'
        'openssl'
        'sdl2'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_yquake2() {
    local url="https://github.com/yquake2"
    local repos=(
        'ctf'
        'rogue'
        'xatrix'
        'yquake2'
    )
    for repo in "${repos[@]}"; do
        if [[ "${repo}" == "yquake2" ]]; then
            gitPullOrClone "${md_build}/${repo}"
        else
            gitPullOrClone "${md_build}/${repo}" "${url}/${repo}"
        fi
    done

    # Set Default Config Path(s)
    sed -e "s|#define CFGDIR \".yq2\"|#define CFGDIR \"ArchyPie/configs/${md_id}\"|g" -i "${md_build}/${md_id}/src/common/header/common.h"
}

function build_yquake2() {
    local dirs=(
        'ctf'
        'rogue'
        'xatrix'
        'yquake2'
    )
    for dir in "${dirs[@]}"; do
        make -C "${md_build}/${dir}" clean
        make -C "${md_build}/${dir}"
    done
    md_ret_require="${md_build}/${md_id}/release/quake2"
}

function install_yquake2() {
    md_ret_files=(
        'yquake2/LICENSE'
        'yquake2/README.md'
        'yquake2/release/baseq2'
        'yquake2/release/q2ded'
        'yquake2/release/quake2'
        'yquake2/release/ref_gl1.so'
        'yquake2/release/ref_gl3.so'
        'yquake2/release/ref_soft.so'
    )
    local dirs=(
        'ctf'
        'rogue'
        'xatrix'
    )
    for dir in "${dirs[@]}"; do
        install -Dm644 "${md_build}/${dir}/release/game.so" -t "${md_inst}/${dir}"
    done
}

function _game_data_yquake2() {
    local portname
    portname="quake2"

    if [[ ! -f "${romdir}/ports/${portname}/baseq2/pak1.pak" ]] && [[ ! -f "${romdir}/ports/${portname}/baseq2/pak0.pak" ]]; then
        downloadAndExtract "https://deponie.yamagi.org/quake2/idstuff/q2-314-demo-x86.exe" "${romdir}/ports/${portname}/baseq2" -j -LL
        # Remove Files That Are Not Required
        local file
        while read -r file; do
            rm -f "${file}"
        done < <(find "${romdir}/ports/${portname}" -maxdepth 2 -name "*.*" ! -name "*.pak")
    fi

    chown -R "${user}:${user}" "${romdir}/ports/${portname}"
}

function _add_games_yquake2() {
    local cmd="$1"
    local dir
    local game
    local portname
    declare -A games=(
        ['baseq2/pak0.pak']="Quake II"
        ['ctf/pak0.pak']="Quake II: Third Wave Capture The Flag"
        ['rogue/pak0.pak']="Quake II: Mission Pack 2: Ground Zero"
        ['xatrix/pak0.pak']="Quake II: Mission Pack 1: The Reckoning"
    )

    # Create .sh Files For Each Game Found. Uppercase Filenames Will Be Converted to Lowercase.
    for game in "${!games[@]}"; do
        portname="quake2"
        dir="${romdir}/ports/${portname}/${game%/*}"
        if [[ "${md_mode}" == "install" ]]; then
            pushd "${dir}" || return
            perl-rename 'y/A-Z/a-z/' [^.-]{*,*/*}
            popd || return
        fi
        if [[ -f "${dir}/${game##*/}" ]]; then
            addPort "${md_id}" "${portname}" "${games[$game]}" "${cmd}" "${game%%/*}"
        fi
    done
}

function configure_yquake2() {
    local portname
    portname="quake2"

    if [[ "$md_mode" == "install" ]]; then
        local dirs=(
            'baseq2'
            'ctf'
            'rogue'
            'xatrix'
        )
        mkRomDir "ports/${portname}"
        for dir in "${dirs[@]}"; do
            mkRomDir "ports/${portname}/${dir}"
        done
        _game_data_yquake2
    fi

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${portname}/${md_id}/"

    local params=("-datadir ${romdir}/ports/${portname}" "+set game %ROM%")

    if isPlatform "gles3"; then
        params+=("+set vid_renderer gl3")
    elif isPlatform "gl" || isPlatform "mesa"; then
        params+=("+set vid_renderer gl1")
    elif isPlatform "kms"; then
        params+=("+set r_mode -1" "+set r_customwidth %XRES%" "+set r_customheight %YRES%" "+set r_vsync 1")
    else
        params+=("+set vid_renderer soft")
    fi

    _add_games_yquake2 "${md_inst}/${portname} ${params[*]}"
}
