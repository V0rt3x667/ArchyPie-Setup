#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="love"
rp_module_desc="Love - 2D Game Engine for Lua"
rp_module_help="Copy your Love games to $romdir/love"
rp_module_licence="ZLIB https://raw.githubusercontent.com/love2d/love/master/license.txt"
rp_module_repo="git https://github.com/love2d/love 11.4"
rp_module_section="opt"
rp_module_flags="!aarch64"

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
    local params=(--prefix="$md_inst")

    ./configure "${params[@]}"
    make clean
    make
    md_ret_require="$md_build/src/love"
}

function install_love() {
    make install
}

function game_data_love() {
    # get Mari0 1.6.2 (freeware game data)
    if [[ ! -f "$romdir/love/mari0.love" ]]; then
        downloadAndExtract "https://github.com/Stabyourself/mari0/archive/1.6.2.tar.gz" "$__tmpdir/mari0" --strip-components 1
        pushd "$__tmpdir/mari0"
        zip -qr "$romdir/love/mari0.love" .
        popd
        rm -fr "$__tmpdir/mari0"
        chown $user:$user "$romdir/love/mari0.love"
    fi
}

function configure_love() {
    setConfigRoot ""

    mkRomDir "love"

    if [[ "$md_id" == love-0.10.2 ]]; then
        addEmulator 0 "$md_id" "love" "$md_inst/bin/love %ROM%"
    else
        addEmulator 1 "$md_id" "love" "$md_inst/bin/love %ROM%"
    fi
    addSystem "love"

    [[ "$md_mode" == "install" ]] && game_data_love
}
