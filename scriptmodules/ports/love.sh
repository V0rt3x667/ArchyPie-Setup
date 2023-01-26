#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="love"
rp_module_desc="Love: A 2D Game Engine for Lua"
rp_module_help="Copy Love Games to: ${romdir}/love"
rp_module_licence="ZLIB https://raw.githubusercontent.com/love2d/love/master/license.txt"
rp_module_repo="git https://github.com/love2d/love :_get_branch_love"
rp_module_section="opt"
rp_module_flags=""

function _get_branch_love() {
    download "https://api.github.com/repos/love2d/${md_id}/releases" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_love() {
    local depends=(
        'freetype2'
        'libmodplug'
        'libtheora'
        'libvorbis'
        'luajit'
        'mpg123'
        'openal'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_love() {
    gitPullOrClone
}

function build_love() {
    ./platform/unix/automagic
    ./configure --prefix="${md_inst}"
    make clean
    make
    md_ret_require="${md_build}/src/${md_id}"
}

function install_love() {
    make install
}

function _game_data_love() {
    # Get Mari0 1.6.2 (Freeware Game Data)
    if [[ ! -f "${romdir}/${md_id}/mari0.love" ]]; then
        downloadAndExtract "https://github.com/Stabyourself/mari0/archive/1.6.2.tar.gz" "${__tmpdir}/mari0" --strip-components 1
        pushd "${__tmpdir}/mari0" || return
        zip -qr "${romdir}/${md_id}/mari0.love" .
        popd || return
        rm -fr "${__tmpdir}/mari0"
        chown "${user}:${user}" "${romdir}/${md_id}/mari0.love"
    fi
}

function configure_love() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "${md_id}"
        _game_data_love
    fi

    setConfigRoot ""

    addEmulator 1 "${md_id}" "${md_id}" "${md_inst}/bin/${md_id} %ROM%"
    
    addSystem "${md_id}"
}
