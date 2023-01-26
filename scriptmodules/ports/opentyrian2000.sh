#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="opentyrian2000"
rp_module_desc="OpenTyrian2000: Port of the Classic DOS Game Tyrian"
rp_module_licence="GPL2 https://raw.githubusercontent.com/KScl/opentyrian2000/master/COPYING"
rp_module_repo="git https://github.com/KScl/opentyrian2000 master"
rp_module_section="opt"
rp_module_flags=""

function depends_opentyrian2000() {
    local depends=(
        'sdl2_net'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_opentyrian2000() {
    gitPullOrClone

    # Set Config Path & Fullscreen
    applyPatch "${md_data}/01_set_default_config_path_fullscreen.patch"
}

function build_opentyrian2000() {
    rpSwap on 512
    make clean
    make TYRIAN_DIR="${md_inst}"
    rpSwap off
    md_ret_require="${md_build}/${md_id}"
}

function install_opentyrian2000() {
    make install prefix="${md_inst}"
}

function _game_data_opentyrian2000() {
    if [[ ! -d "${romdir}/ports/${md_id}/data" ]]; then
        cd "${__tmpdir}" || exit
        downloadAndExtract "https://www.camanis.net/tyrian/tyrian2000.zip" "${romdir}/ports/${md_id}/data" -j
        chown -R "${user}:${user}" "${romdir}/ports/${md_id}"
    fi
}

function configure_opentyrian2000() {
    [[ "${md_mode}" == "install" ]] && mkRomDir "ports/${md_id}" && _game_data_opentyrian2000
    
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    addPort "${md_id}" "${md_id}" "OpenTyrian2000" "${md_inst}/bin/${md_id} --data ${romdir}/ports/${md_id}/data/"
}
