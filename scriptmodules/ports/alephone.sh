#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="alephone"
rp_module_desc="Aleph One: Marathon Game Engine"
rp_module_licence="GPL3 https://raw.githubusercontent.com/Aleph-One-Marathon/alephone/master/COPYING"
rp_module_repo="git https://github.com/Aleph-One-Marathon/alephone :_get_branch_alephone"
rp_module_section="opt"
rp_module_flags="!mali"

function _get_branch_alephone() {
    download "https://api.github.com/repos/Aleph-One-Marathon/${md_id}/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_alephone() {
    local depends=(
        'autoconf-archive'
        'boost-libs'
        'boost'
        'ffmpeg'
        'glu'
        'libmad'
        'libvorbis'
        'miniupnpc'
        'sdl2_image'
        'sdl2_net'
        'sdl2_ttf'
        'sdl2'
        'speex'
        'zziplib'
    )
    getDepends "${depends[@]}"
}

function sources_alephone() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|/.alephone|/ArchyPie/configs/${md_id}|g" -i "${md_build}/Source_Files/CSeries/cspaths_sdl.cpp"
}

function build_alephone() {
    autoreconf -iv
    ./configure --prefix="${md_inst}"
    make clean
    make
    md_ret_require="${md_build}/Source_Files/${md_id}"
}

function install_alephone() {
    make install
}

function _game_data_alephone() {
    local version
    local release_url

    version="$(_get_branch_alephone)"
    release_url="https://github.com/Aleph-One-Marathon/alephone/releases/download/${version}"

    if [[ ! -f "${romdir}/ports/${md_id}/Marathon/Shapes.shps" ]]; then
        downloadAndExtract "${release_url}/Marathon-${version/release-/}-Data.zip" "${romdir}/ports/${md_id}"
    fi

    if [[ ! -f "${romdir}/ports/${md_id}/Marathon 2/Shapes.shpA" ]]; then
        downloadAndExtract "${release_url}/Marathon2-${version/release-/}-Data.zip" "${romdir}/ports/${md_id}"
    fi

    if [[ ! -f "${romdir}/ports/${md_id}/Marathon Infinity/Shapes.shpA" ]]; then
        downloadAndExtract "${release_url}/MarathonInfinity-${version/release-/}-Data.zip" "${romdir}/ports/${md_id}"
    fi

    chown -R "${user}:${user}" "${romdir}/ports/${md_id}"
}

function configure_alephone() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "ports/${md_id}"
        _game_data_alephone
    fi

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    addPort "${md_id}" "${md_id}" "Aleph One Engine: Marathon" "${md_inst}/bin/${md_id} %ROM%" "${romdir}/ports/${md_id}/Marathon/"
    addPort "${md_id}" "${md_id}" "Aleph One Engine: Marathon 2: Durandal" "${md_inst}/bin/${md_id} %ROM%" "${romdir}/ports/${md_id}/Marathon 2/"
    addPort "${md_id}" "${md_id}" "Aleph One Engine: Marathon Infinity" "${md_inst}/bin/${md_id} %ROM%" "${romdir}/ports/${md_id}/Marathon Infinity/"
}
