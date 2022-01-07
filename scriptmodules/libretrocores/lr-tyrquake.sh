#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-tyrquake"
rp_module_desc="Quake Libretro Core"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/tyrquake/master/gnu.txt"
rp_module_repo="git https://github.com/libretro/tyrquake.git master"
rp_module_section="opt"

function sources_lr-tyrquake() {
    gitPullOrClone
}

function build_lr-tyrquake() {
    make clean
    make
    md_ret_require="$md_build/tyrquake_libretro.so"
}

function install_lr-tyrquake() {
    md_ret_files=(
        'LICENSE.txt'
        'readme-id.txt'
        'readme.txt'
        'tyrquake_libretro.so'
    )
}

function game_data_lr-tyrquake() {
    if [[ ! -f "$romdir/ports/quake/id1/pak0.pak" ]]; then
        getDepends lhasa
        mkUserDir "$romdir/ports"
        mkUserDir "$romdir/ports/quake"
        local temp="$(mktemp -d)"
        # download / unpack / install quake shareware files
        downloadAndExtract "$__archive_url/quake106.zip" "$temp"
        pushd "$temp"
        lhasa ef resource.1
        cp -rf id1 "$romdir/ports/quake/"
        popd
        rm -rf "$temp"
        chown -R $user:$user "$romdir/ports/quake"
        chmod 644 "$romdir/ports/quake/id1/"*
    fi
}

function _add_games_lr-tyrquake() {
    local cmd="$1"
    declare -A games=(
        ['id1']="Quake"
        ['hipnotic']="Quake Mission Pack 1 - Scourge of Armagon"
        ['rogue']="Quake Mission Pack 2 - Dissolution of Eternity"
        ['dopa']="Quake Episode 5 - Dimensions of the Past"
    )
    local dir
    local pak
    for dir in "${!games[@]}"; do
        pak="$romdir/ports/quake/$dir/pak0.pak"
        if [[ -f "$pak" ]]; then
            addPort "$md_id" "quake" "${games[$dir]}" "$cmd" "$pak"
        fi
    done
}

function add_games_lr-tyrquake() {
    _add_games_lr-tyrquake "$md_inst/tyrquake_libretro.so"
}

function configure_lr-tyrquake() {
    setConfigRoot "ports"
    mkRomDir "ports/quake"

    [[ "$md_mode" == "install" ]] && game_data_lr-tyrquake

    add_games_lr-tyrquake

    ensureSystemretroconfig "ports/quake"
}
