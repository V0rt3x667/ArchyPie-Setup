#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="tyrquake"
rp_module_desc="TyrQuake: Quake Port"
rp_module_licence="GPL2 https://disenchant.net/git/tyrquake.git/plain/gnu.txt"
rp_module_repo="git git://disenchant.net/tyrquake master"
rp_module_section="opt"

function depends_tyrquake() {
    local depends=('sdl2')
    if isPlatform "gl" || isPlatform "mesa"; then
        depends+=('libglvnd')
    fi
    getDepends "${depends[@]}"
}

function sources_tyrquake() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|\"%s/.tyrquake\"|\"%s/ArchyPie/configs/${md_id}\"|g" -i "${md_build}/common/sys_unix.c"
}

function build_tyrquake() {
    local binary
    local params=('USE_SDL=Y' 'USE_XF86DGA=N')

    if isPlatform "gl" || isPlatform "mesa"; then
        binary="bin/tyr-glquake"
    else
        binary="bin/tyr-quake'"
    fi

    make clean
    make "${params[@]}" "${binary}"
    md_ret_require=("${md_build}/${binary}")
}

function install_tyrquake() {
    md_ret_files=(
        'bin'
        'changelog.txt'
        'gnu.txt'
        'readme-id.txt'
        'readme.txt'
    )
}

function configure_tyrquake() {
    local portname
    portname="quake"

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${portname}/${md_id}/"

    if [[ "${md_mode}" == "install" ]]; then
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

        # Get Shareware Data If Required
        _game_data_lr-tyrquake
    fi

    local binary
    local params=("-basedir ${romdir}/ports/${portname}" '-game %QUAKEDIR%' '-fullscreen')

    isPlatform "kms" && params+=('-width %XRES%' '-height %YRES%' '+set vid_vsync 2')

    if isPlatform "gl" || isPlatform "mesa"; then
        binary="${md_inst}/bin/tyr-glquake"
    else
        binary="${md_inst}/bin/tyr-quake'"
    fi

    _add_games_lr-tyrquake "${binary} ${params[*]}"
}
