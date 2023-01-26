#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="opentyrian"
rp_module_desc="OpenTyrian: Port of the Classic DOS Game Tyrian"
rp_module_licence="GPL2 https://raw.githubusercontent.com/opentyrian/opentyrian/master/COPYING"
rp_module_repo="git https://github.com/opentyrian/opentyrian :_get_branch_opentyrian"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_opentyrian() {
    download "https://api.github.com/repos/opentyrian/opentyrian/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_opentyrian() {
    local depends=(
        'sdl2_net'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_opentyrian() {
    gitPullOrClone

    # Set Config Path & Fullscreen
    applyPatch "${md_data}/01_set_default_config_path_fullscreen.patch"
}

function build_opentyrian() {
    rpSwap on 512
    make clean
    make TYRIAN_DIR="${md_inst}"
    rpSwap off
    md_ret_require="${md_build}/${md_id}"
}

function install_opentyrian() {
    make install prefix="${md_inst}"
}

function _game_data_opentyrian() {
    if [[ ! -d "${romdir}/ports/${md_id}/data" ]]; then
        cd "${__tmpdir}" || exit
        downloadAndExtract "https://www.camanis.net/tyrian/tyrian21.zip" "${romdir}/ports/${md_id}/data" -j
        chown -R "${user}:${user}" "${romdir}/ports/${md_id}"
    fi
}

function configure_opentyrian() {
    [[ "${md_mode}" == "install" ]] && mkRomDir "ports/${md_id}" && _game_data_opentyrian
    
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    addPort "${md_id}" "${md_id}" "OpenTyrian" "${md_inst}/bin/${md_id} --data ${romdir}/ports/${md_id}/data/"
}
