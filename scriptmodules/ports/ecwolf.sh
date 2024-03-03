#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="ecwolf"
rp_module_desc="ECWolf: Advanced Source Port For Wolfenstein 3D, Spear of Destiny & Super 3D Noah's Ark"
rp_module_licence="GPL2 https://bitbucket.org/ecwolf/ecwolf/raw/854becdaa0f59291f619621003cfed67dd6f5c96/docs/license-gpl.txt"
rp_module_help="Copy Wolfenstein 3D, Spear of Destiny & Super 3D Noah's Ark Game Files To: ${romdir}/ports/wolf3d"
rp_module_repo="git https://bitbucket.org/ecwolf/ecwolf master"
rp_module_section="opt"
rp_module_flags=""

function depends_ecwolf() {
    local depends=(
        'bzip2'
        'clang'
        'cmake'
        'flac'
        'fluidsynth'
        'libjpeg'
        'libmodplug'
        'libvorbis'
        'lld'
        'ninja'
        'opusfile'
        'sdl2_mixer'
        'sdl2_net'
        'sdl2'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_ecwolf() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|\"%s/.config/\"|\"%s/ArchyPie/configs/\"|g" -i "${md_build}/src/filesys.cpp"
    sed -e "s|\"%s/.local/share/\"|\"%s/ArchyPie/configs/\"|g" -i "${md_build}/src/filesys.cpp"

    # Set Binary Dir to "bin"
    sed "s|set(CMAKE_INSTALL_BINDIR \"games\")|set(CMAKE_INSTALL_BINDIR \"bin\")|g" -i "${md_build}/CMakeLists.txt"
}

function build_ecwolf() {
    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_C_COMPILER="clang" \
        -DCMAKE_CXX_COMPILER="clang++" \
        -DCMAKE_EXE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_MODULE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_SHARED_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DGPL="ON" \
        -DNO_GTK="ON" \
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

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${portname}/${md_id}/"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "ports/${portname}"

        # Add Shareware Files
        _game_data_wolf4sdl

        # Set Default Settings
        local config
        config="$(mktemp)"

        iniConfig ' = ' '' "${config}"
        iniSet "BaseDataPaths" "\"${romdir}/ports/${portname}\";"
        iniSet "Vid_FullScreen" "1;"
        iniSet "Vid_Vsync" "1;"

        copyDefaultConfig "${config}" "${md_conf_root}/${portname}/${md_id}/ecwolf.cfg"
        rm "${config}"

        # Create A Launcher Script
        cat > "${md_inst}/${md_id}.sh" << _EOF_
#!/bin/bash
wad="\${1}"
wad="\${wad##*.}"
"${md_inst}/bin/${md_id}" --data "\${wad}"
_EOF_
        chmod +x "${md_inst}/${md_id}.sh"
    fi

    _add_games_wolf4sdl "${md_inst}/${md_id}.sh %ROM%"
}
