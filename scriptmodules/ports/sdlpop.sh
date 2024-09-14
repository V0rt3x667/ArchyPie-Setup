#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="sdlpop"
rp_module_desc="SDLPoP: Open-Source Port of Prince of Persia"
rp_module_licence="GPL3 https://raw.githubusercontent.com/NagyD/SDLPoP/master/COPYING"
rp_module_repo="git https://github.com/NagyD/SDLPoP master"
rp_module_section="opt"

function depends_sdlpop() {
    local depends=(
        'libpng'
        'sdl2_image'
        'sdl2_mixer'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_sdlpop() {
    gitPullOrClone

    # Set Default Config Path(s)
    applyPatch "${md_data}/01_set_default_config_path.patch"
}

function build_sdlpop() {
    make -C src clean
    make -C src
    md_ret_require="${md_build}/prince"
}

function install_sdlpop() {
    md_ret_files=(
        'COPYING'
        'data'
        'doc'
        'prince'
    )

    cp -v SDLPoP.ini "${md_inst}/SDLPoP.ini.def"
    sed -e "s|use_correct_aspect_ratio = false|use_correct_aspect_ratio = true|g" -i "${md_inst}/SDLPoP.ini.def"
}

function configure_sdlpop() {
    local portname
    portname="sdlpop"

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    if [[ "${md_mode}" == "install" ]]; then
        copyDefaultConfig "${md_inst}/SDLPoP.ini.def" "${md_conf_root}/${md_id}/SDLPoP.ini"

        chown -R "${__user}":"${__group}" "${md_conf_root}/${md_id}"
    fi

    addPort "${md_id}" "${portname}" "Prince of Persia" "pushd ${md_inst}; ${md_inst}/prince full; pushd"
}
