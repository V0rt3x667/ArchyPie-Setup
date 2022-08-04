#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-tyrquake"
rp_module_desc="Quake Libretro Core"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/tyrquake/master/gnu.txt"
rp_module_repo="git https://github.com/libretro/tyrquake.git master"
rp_module_section="opt"

function depends_lr-tyrquake() {
    getdepends perl-rename
}

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

function _game_data_lr-tyrquake() {
    if [[ ! -f "$romdir/ports/quake/id1/pak0.pak" ]]; then
        getDepends lhasa
        local temp="$(mktemp -d)"
        # Download, unpack & install Quake shareware files.
        downloadAndExtract "$__archive_url/quake106.zip" "$temp"
        pushd "$temp"
        lha ef resource.1
        cp -rf id1 "$romdir/ports/quake/"
        popd
        rm -rf "$temp"
        chown -R "$user:$user" "$romdir/ports/quake"
    fi
}

function _add_games_lr-tyrquake() {
    local cmd="$1"
    local dir
    local game
    declare -A games=(
        ['id1/pak0.pak']="Quake"
        ['hipnotic/pak0.pak']="Quake: Mission Pack 1: Scourge of Armagon"
        ['rogue/pak0.pak']="Quake: Mission Pack 2: Dissolution of Eternity"
        ['dopa/pak0.pak']="Quake: Episode 5: Dimensions of the Past"
    )

    # Create .sh files for each game found. Uppercase filenames will be converted to lowercase.
    for game in "${!games[@]}"; do
        dir="$romdir/ports/quake"
        pushd "$dir/${game%%/*}"
        perl-rename 'y/A-Z/a-z/' [^.-]*
        popd
        if [[ -f "$dir/$game" ]]; then
            if isPlatform "rpi4"; then
                if [[ "$cmd" =~ "darkplaces-sdl-gles" ]]; then
                    addPort "$md_id-gles" "quake" "${games[$game]}" "$cmd" "$dir/$game"
                else
                    addPort "$md_id" "quake" "${games[$game]}" "$cmd" "$dir/$game"
                fi
            else
                addPort "$md_id" "quake" "${games[$game]}" "$cmd" "$dir/$game"
            fi
        fi
    done
}

function configure_lr-tyrquake() {
    setConfigRoot "ports"

    mkRomDir "ports/quake"

    defaultRAConfig "quake"

    if [[ "$md_mode" == "install" ]]; then
        _game_data_lr-tyrquake && _add_games_lr-tyrquake "$md_inst/tyrquake_libretro.so"
    fi
}
