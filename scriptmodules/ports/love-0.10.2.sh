#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="love-0.10.2"
rp_module_desc="Love - 2d Game Engine v0.10.2"
rp_module_help="Copy your Love games to $romdir/love"
rp_module_licence="ZLIB https://raw.githubusercontent.com/love2d/love/0.10.2/license.txt"
rp_module_repo="git https://github.com/love2d/love 0.10.2"
rp_module_section="opt"
rp_module_flags="!aarch64"

function depends_love-0.10.2() {
    depends_love
}

function sources_love-0.10.2() {
    gitPullOrClone
    # LUA_VERSION_NUM defined as 501 but requires the newer luaL_Reg named struct.
    # adjusting the compatibility code #if to check for LUA_VERSION_NUM >= 501 fixes this.
    sed -i "s/LUA_VERSION_NUM > 501/LUA_VERSION_NUM >= 501/" "$md_build/src/libraries/luasocket/libluasocket/lua.h"
}

function build_love-0.10.2() {
    build_love
}

function install_love-0.10.2() {
    install_love
}

function game_data_love-0.10.2() {
    _game_data_love
}

function configure_love-0.10.2() {
    setConfigRoot ""

    mkRomDir "love"

    addEmulator 0 "$md_id" "love" "$md_inst/bin/love %ROM%"
    addSystem "love"
}
