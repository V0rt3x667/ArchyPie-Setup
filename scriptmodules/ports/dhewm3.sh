#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="dhewm3"
rp_module_desc="dhewm3 - DOOM 3 Port"
rp_module_licence="GPL3 https://raw.githubusercontent.com/dhewm/dhewm3/master/COPYING.txt"
rp_module_repo="git https://github.com/dhewm/dhewm3.git :_get_branch_dhewm3"
rp_module_section="ports"
rp_module_flags="!all 64bit"

function _get_branch_dhewm3() {
    download https://api.github.com/repos/dhewm/dhewm3/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_dhewm3() {
    local depends=(
        'cmake'
        'curl'
        'libjpeg'
        'libvorbis'
        'openal'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_dhewm3() {
    gitPullOrClone
}

function build_dhewm3() {
    mkdir build
    cd build

    LDFLAGS+=" -Wl,-rpath='$md_inst'"
    cmake ../neo \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DREPRODUCIBLE_BUILD=1 \
        -DD3XP=1 \
        -DDEDICATED=1 \
        -Wno-dev
    make clean
    make
    md_ret_require="$md_build/build/dhewm3"
}

function install_dhewm3() {
    cd build
    make install

#    md_ret_files=(
#        'build/dhewm3'
#        'build/dhewm3ded'
#        'build/base.so'
#        'build/d3xp.so'
#    )
}

function _game_data_dhewm3() {
    local url
    url="https://files.holarse-linuxgaming.de/native/Spiele/Doom%203/Demo/doom3-linux-1.1.1286-demo.x86.run"
    if [[ -f "$romdir/ports/doom3/base/pak000.pk4" ]] || [[ -f "$romdir/ports/doom3/demo/demo00.pk4" ]]; then
        return
    else
        download "$url" "$romdir/ports/doom3"
        chmod +x "$romdir/ports/doom3/doom3-linux-1.1.1286-demo.x86.run"
        cd "$romdir/ports/doom3"
        ./doom3-linux-1.1.1286-demo.x86.run --tar xf demo/ && rm "$romdir/ports/doom3/doom3-linux-1.1.1286-demo.x86.run"
        chown "$user:$user" "$romdir/ports/doom3/demo"
    fi
}

function _add_games_dhewm3() {
    local cmd="$1"
    local dir
    local pak
    declare -A games=(
        ['base/pak000']="Doom III"
        ['demo/demo00']="Doom III (Demo)"
        ['d3xp/pak000']="Doom III - Resurrection of Evil"
    )
    for game in "${!games[@]}"; do
        pak="$romdir/ports/doom3/$game.pk4"
        if [[ -f "$pak" ]]; then
            addPort "$md_id" "doom3" "${games[$game]}" "$cmd" "${game%%/*}"
        fi
    done
}

function configure_dhewm3() {
    mkRomDir "ports/doom3"

    moveConfigDir "$home/.config/dhewm3" "$md_conf_root/doom3"

    [[ "$md_mode" == "install" ]] && _game_data_dhewm3

    local basedir="$romdir/ports/doom3"
    _add_games_dhewm3 "$md_inst/bin/dhewm3 +set fs_basepath $basedir +set r_fullscreen 1 +set fs_game %ROM%"
}
