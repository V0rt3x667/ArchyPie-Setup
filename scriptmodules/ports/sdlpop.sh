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
    depends=(
        'cmake'
        'ninja'
        'sdl2_image'
        'sdl2_mixer'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_sdlpop() {
    gitPullOrClone
}

function build_sdlpop() {
    cmake . \
        -Ssrc \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/prince"
}

function install_sdlpop() {
    md_ret_files=(
        'COPYING'
        'data'
        'doc'
        'prince'
    )
    cp -v "SDLPoP.ini" "${md_inst}/SDLPoP.ini.def"
    sed -e "s|use_correct_aspect_ratio = false|use_correct_aspect_ratio = true|g" -i "${md_inst}/SDLPoP.ini.def"
}

function configure_sdlpop() {
    copyDefaultConfig "${md_inst}/SDLPoP.ini.def" "${md_conf_root}/${md_id}/SDLPoP.ini"

    moveConfigFile "${md_inst}/SDLPoP.ini" "${md_conf_root}/${md_id}/SDLPoP.ini"
    moveConfigFile "${md_inst}/PRINCE.SAV" "${md_conf_root}/${md_id}/PRINCE.SAV"
    moveConfigFile "${md_inst}/QUICKSAVE.SAV" "${md_conf_root}/${md_id}/QUICKSAVE.SAV"
    moveConfigFile "${md_inst}/SDLPoP.cfg" "${md_conf_root}/${md_id}/SDLPoP.cfg"
    chown -R "${user}:${user}" "${md_conf_root}/${md_id}"

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}"

    addPort "${md_id}" "${md_id}" "Prince of Persia" "pushd $md_inst; ${md_inst}/prince full; pushd"
}
