#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="openttd"
rp_module_desc="OpenTTD - Game Engine for Transport Tycoon Deluxe"
rp_module_licence="GPL2 https://raw.githubusercontent.com/OpenTTD/OpenTTD/master/COPYING.md"
rp_module_repo="git https://github.com/OpenTTD/OpenTTD.git :_get_branch_openttd"
rp_module_section="opt"
rp_module_flags="sdl2 !mali"

function _get_branch_openttd() {
    download https://api.github.com/repos/OpenTTD/OpenTTD/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_openttd() {
    local depends=(
        'cmake'
        'doxygen'
        'fluidsynth'
        'fontconfig'
        'freetype2'
        'icu'
        'libpng'
        'lzo'
        'ninja'
        'sdl2'
        'zlib'
    )
}

function sources_openttd() {
    gitPullOrClone
    sed -i '/sse/d;/SSE/d' "$md_build/CMakeLists.txt"
}

function build_openttd() {
    mkdir build
    cd build
    cmake .. \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=$md_inst \
        -DCMAKE_INSTALL_BINDIR="." \
        -DCMAKE_INSTALL_DATADIR="data" \
        -Wno-dev
    ninja
}

function install_openttd() {
    ninja -C build install
}

function configure_openttd() {
    addPort "$md_id" "openttd" "OpenTTD" "$md_inst/openttd"

    [[ "$md_mode" == "remove" ]] && return

    isPlatform "dispmanx" && setBackend "$md_id" "dispmanx"

    local dir
    for dir in .config .local/share; do
        moveConfigDir "$home/$dir/openttd" "$md_conf_root/openttd"
    done
}
