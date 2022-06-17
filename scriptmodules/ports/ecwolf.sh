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
        'ninja'
        'opusfile'
        'sdl2_mixer'
        'sdl2_net'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_ecwolf() {
    # updaterevision will fail with: fatal: No names found, cannot describe anything.
    # Need to fetch a full clone of the repo.
    gitPullOrClone "$md_build" "$md_repo_url" "$md_repo_branch" "" 0

    # Set binary dir to bin
    sed s'|set(CMAKE_INSTALL_BINDIR "games")|set(CMAKE_INSTALL_BINDIR "bin")|'g -i "$md_build/CMakeLists.txt"
}

function build_ecwolf() {
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DGPL=ON \
        -DNO_GTK=ON \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="$md_build/build/ecwolf"
}

function install_ecwolf() {
    ninja -C build install/strip
}

function configure_ecwolf() {
    mkRomDir "ports/wolf3d"

    moveConfigDir "$home/.local/share/ecwolf" "$md_conf_root/ecwolf"
    moveConfigDir "$home/.config/ecwolf" "$md_conf_root/ecwolf"

    [[ "$md_mode" == "install" ]] && _game_data_wolf4sdl

    _add_games_wolf4sdl "$md_inst/bin/ecwolf --data %ROM%"

    iniConfig " = " '' "$configdir/ports/wolf3d/ecwolf.cfg"

    iniSet "BaseDataPaths" "\"$romdir/ports/wolf3d\";"
    iniSet "Vid_FullScreen" "1;"
    iniSet "Vid_Vsync" "1;"

    chown "$user:$user" "$configdir/ports/wolf3d/ecwolf.cfg"
}
