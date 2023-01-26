#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="augustus"
rp_module_desc="Augustus: Enhanced Caesar III Port"
rp_module_licence="AGPL3 https://github.com/Keriew/augustus/blob/master/LICENSE.txt"
rp_module_repo="git https://github.com/Keriew/augustus :_get_branch_augustus"
rp_module_section="opt"
rp_module_flags="!all 64bit"

function _get_branch_augustus() {
    download "https://api.github.com/repos/Keriew/${md_id}/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_augustus() {
    local depends=(
        'cmake'
        'libpng'
        'ninja'
        'sdl2_mixer'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_augustus() {
    gitPullOrClone
}

function build_augustus() {
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/${md_id}"
}

function install_augustus() {
    ninja -C build install/strip
}

function configure_augustus() {
    local portname
    portname="caesar3"

    [[ "${md_mode}" == "install" ]] && mkRomDir "ports/${portname}"

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${portname}/${md_id}"

    addPort "${md_id}" "${portname}" "Caesar III" "${md_inst}/bin/${md_id} ${romdir}/ports/${portname}"
}
