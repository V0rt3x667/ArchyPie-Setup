#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="ecwolf"
rp_module_desc="ECWolf: Advanced Source Port for Wolfenstein 3D, Spear of Destiny & Super 3D Noah's Ark"
rp_module_licence="GPL2 https://bitbucket.org/ecwolf/ecwolf/raw/5065aaefe055bff5a8bb8396f7f2ca5f2e2cab27/docs/license-gpl.txt"
rp_module_help="Copy your Wolfenstein 3D, Spear of Destiny & Super 3D Noah's Ark Game Files To: ${romdir}/ports/wolf3d/"
rp_module_repo="git https://bitbucket.org/ecwolf/ecwolf.git master"
rp_module_section="opt"
rp_module_flags=""

function depends_ecwolf() {
    depends=(
        'cmake'
        'flac'
        'fluidsynth'
        'libjpeg'
        'libmodplug'
        'libvorbis'
        'ninja'
        'opusfile'
        'sdl2_net'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_ecwolf() {
    # "updaterevision" Will Fail With: "fatal: No names found, cannot describe anything", A Full Clone Of The Repo is Required.
    gitPullOrClone "${md_build}" "${md_repo_url}" "${md_repo_branch}" "" 0

    # Set Default Config Path(s)
    sed -e "s|\"%s/.config/\"|\"%s/ArchyPie/configs/\"|g" -i "${md_build}/src/filesys.cpp"
    sed -e "s|\"%s/.local/share/\"|\"%s/ArchyPie/configs/\"|g" -i "${md_build}/src/filesys.cpp"

    # Set Binary Dir to "bin"
    sed "s|set(CMAKE_INSTALL_BINDIR \"games\")|set(CMAKE_INSTALL_BINDIR \"bin\")|g" -i "${md_build}/CMakeLists.txt"
}

function build_ecwolf() {
    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DGPL="ON" \
        -DNO_GTK="ON" \
        -DINTERNAL_SDL_MIXER="ON" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require="${md_build}/build/${md_id}"
}

function install_ecwolf() {
    ninja -C build install/strip
}

function configure_ecwolf() {
    local portname
    portname="wolf3d"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "ports/${portname}"
        _game_data_wolf4sdl
    fi

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${portname}/${md_id}/"

    if [[ "${md_mode}" == "install" ]]; then
        local config

        # Set Default Settings
        config="$(mktemp)"
        iniConfig ' = ' '' "${config}"
        iniSet "BaseDataPaths" "\"${romdir}/ports/${portname}\";"
        iniSet "Vid_FullScreen" "1;"
        iniSet "Vid_Vsync" "1;"

        copyDefaultConfig "${config}" "${md_conf_root}/${portname}/${md_id}/ecwolf.cfg"
        rm "${config}"
    fi

    _add_games_wolf4sdl "${md_inst}/bin/${md_id} --data %ROM%"
}
