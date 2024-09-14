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
    gitPullOrClone 

    # Clone Addon Repos
    local repos=(
        'ctf'
        'rogue'
        'xatrix'
    )
    for repo in "${repos[@]}"; do
        gitPullOrClone "${md_build}/${repo}" "${md_repo_url%/*}/${repo}"
    done

    # Set Default Config Path(s)
    sed -e "s|#define CFGDIR \".yq2\"|#define CFGDIR \"ArchyPie/configs/${md_id}\"|g" -i "${md_build}/src/common/header/common.h"
}

function build_yquake2() {
    # Build yquake2
    make clean
    make

    # Build Addons
    local dirs=(
        'ctf'
        'rogue'
        'xatrix'
    )
    for dir in "${dirs[@]}"; do
        make -C "${md_build}/${dir}" clean
        make -C "${md_build}/${dir}"
    done
    md_ret_require="${md_build}/release/quake2"
}

function install_yquake2() {
    md_ret_files=(
        'LICENSE'
        'README.md'
        'release/baseq2'
        'release/q2ded'
        'release/quake2'
        'release/ref_gl1.so'
        'release/ref_gl3.so'
        'release/ref_soft.so'
    )

    # Install Addons
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

    chown -R "${__user}":"${__group}" "${romdir}/ports/${portname}"
}

function _add_games_yquake2() {
    local cmd="${1}"
    local dir
    local game
    local portname
    local wad

    declare -A games=(
        ['baseq2/pak0.pak']="Quake II"
        ['ctf/pak0.pak']="Quake II: Third Wave Capture The Flag"
        ['rogue/pak0.pak']="Quake II: Mission Pack 2: Ground Zero"
        ['xatrix/pak0.pak']="Quake II: Mission Pack 1: The Reckoning"
    )

    for game in "${!games[@]}"; do
        portname="quake2"
        dir="${romdir}/ports/${portname}/${game%%/*}"
        wad="${romdir}/ports/${portname}/${game}"
        # Convert Uppercase Filenames To Lowercase
        [[ "${md_mode}" == "install" ]] && changeFileCase "${dir}"
        # Create Launch Scripts For Each Game Found
        if [[ -f "${wad}" ]]; then
            addPort "${md_id}" "${portname}" "${games[${game}]}" "${cmd}" "${wad}"
        fi
    done
}

function configure_yquake2() {
    local portname
    portname="quake2"

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${portname}/${md_id}/"

    if [[ "${md_mode}" == "install" ]]; then
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

        # Create A Launcher Script
        local params=("-datadir ${romdir}/ports/${portname}")

        if isPlatform "gl" || isPlatform "gles3"; then
            params+=("+set vid_renderer gl3")
        elif isPlatform "mesa"; then
            params+=("+set vid_renderer gl1")
        elif isPlatform "kms"; then
            params+=("+set r_mode -1" "+set r_customwidth %XRES%" "+set r_customheight %YRES%" "+set r_vsync 1")
        else
            params+=("+set vid_renderer soft")
        fi

        cat > "${md_inst}/${md_id}.sh" << _EOF_
#!/bin/bash -xv
pak="\${1}"
game="\${pak##*/quake2/}"
game="\${game%%/*}"

${md_inst}/quake2 ${params[*]} +set game \${game}
_EOF_
        chmod +x "${md_inst}/${md_id}.sh"

        _game_data_yquake2
    fi

    _add_games_yquake2 "${md_inst}/${md_id}.sh %ROM%"
}
