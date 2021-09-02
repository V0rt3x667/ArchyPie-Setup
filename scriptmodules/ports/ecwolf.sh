#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="ecwolf"
rp_module_desc="ECWolf - Advanced Source Port for Wolfenstein 3D, Spear of Destiny & Super 3D Noah's Ark"
rp_module_licence="GPL2 https://bitbucket.org/ecwolf/ecwolf/raw/5065aaefe055bff5a8bb8396f7f2ca5f2e2cab27/docs/license-gpl.txt"
rp_module_help="Copy your Wolfenstein 3D, Spear of Destiny & Super 3D Noah's Ark Game Files to $romdir/ports/wolf3d/"
rp_module_repo="git https://bitbucket.org/ecwolf/ecwolf.git master"
rp_module_section="opt"
rp_module_flags=""

function depends_ecwolf() {
    depends=(
        'cmake'
        'flac'
        'fluidsynth'
        'gtk3'
        'libjpeg'
        'libmodplug'
        'libvorbis'
        'opusfile'
        'sdl2_mixer'
        'sdl2_net'
    )
    getDepends "${depends[@]}"
}

function sources_ecwolf() {
    gitPullOrClone
}

function build_ecwolf() {
    mkdir build
    cd build
    cmake .. \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_TYPE=Release \
        -DGPL=OFF
    make clean
    make
    md_ret_require="$md_build/build/ecwolf"
}

function install_ecwolf() {
    cd build
    make install
    mv "$md_inst/games" "$md_inst/bin"
}

function _game_data_ecwolf() {
    local dir
    dir="$romdir/ports/wolf3d"

    ##Change Filename Characters to Lowercase
    find "$romdir/ports/wolf3d/" -depth -exec perl-rename 's/(.*)\/([^\/]*)/$1\/\L$2/' {} \;

    if [[ ! -f "$dir/vswap.wl6" && ! -f "$dir/vswap.wl1" ]]; then
        cd "$__tmpdir"
        downloadAndExtract "http://maniacsvault.net/ecwolf/files/shareware/wolf3d14.zip" "$romdir/ports/wolf3d" -j -LL
    fi

    if [[ ! -f "$dir/vswap.sdm" && ! -f "$dir/vswap.sod" && ! -f "$dir/vswap.sd1" ]]; then
        cd "$__tmpdir"
        downloadAndExtract "http://maniacsvault.net/ecwolf/files/shareware/soddemo.zip" "$romdir/ports/wolf3d" -j -LL
    fi

    chown -R "$user:$user" "$romdir/ports/wolf3d"
}

function _add_games_ecwolf(){
    local cmd="$1"
    local game
    local path="$romdir/ports/wolf3d"

    declare -A games=(
        ['n3d']="Super Noah’s Ark 3D"
        ['sd1']="Wolfenstein 3D - Spear of Destiny"
        ['sd2']="Wolfenstein 3D - Spear of Destiny Mission Pack 2 - Return to Danger"
        ['sd3']="Wolfenstein 3D - Spear of Destiny Mission Pack 3 - Ultimate Challenge"
        ['sdm']="Wolfenstein 3D - Spear of Destiny (Shareware)"
        ['sod']="Wolfenstein 3D - Spear of Destiny"
        ['wl1']="Wolfenstein 3D (Shareware)"
        ['wl6']="Wolfenstein 3D"
    )

    for game in "${!games[@]}"; do
        if [[ -f "$path/vswap.$game" ]]; then
            addPort "$md_id" "ecwolf" "${games[$game]}" "$cmd --data $game"
        fi
    done
}

function add_games_ecwolf() {
    _add_games_ecwolf "$md_inst/bin/ecwolf"
}

function configure_ecwolf() {
    mkRomDir "ports/wolf3d"

    moveConfigDir "$home/.local/share/ecwolf" "$md_conf_root/ecwolf"
    moveConfigDir "$home/.config/ecwolf" "$md_conf_root/ecwolf"

    [[ "$md_mode" == "install" ]]

    iniConfig " = " '' "$configdir/ports/ecwolf/ecwolf.cfg"

    iniSet "BaseDataPaths" "\"$romdir/ports/wolf3d\";"
    iniSet "Vid_FullScreen" "1;"
    iniSet "Vid_Vsync" "1;"

    _game_data_ecwolf
    add_games_ecwolf

    chown -R "$user:$user" "$romdir/ports/wolf3d"
}
