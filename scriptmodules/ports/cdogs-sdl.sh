#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="cdogs-sdl"
rp_module_desc="C-Dogs SDL - Classic Overhead Run-and-Gun Game"
rp_module_licence="GPL2 https://raw.githubusercontent.com/cxong/cdogs-sdl/master/COPYING"
rp_module_repo="git https://github.com/cxong/cdogs-sdl.git :_get_branch_cdogs-sdl"
rp_module_section="exp"
rp_module_flags="sdl1 !mali"

function _get_branch_cdogs-sdl() {
    download https://api.github.com/repos/cxong/cdogs-sdl/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_cdogs-sdl() {
    local depends=(
        'cmake'
        'ninja'
        'sdl2'
        'sdl2_image'
        'sdl2_mixer'
    )
    getDepends "${depends[@]}"
}

function sources_cdogs-sdl() {
    gitPullOrClone
    sed 's| -Werror||' -i "$md_build/CMakeLists.txt"
}

function build_cdogs-sdl() {
    cmake . \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DCDOGS_DATA_DIR="$md_inst/" \
        -Wno-dev
    ninja
    md_ret_require="$md_build/src/cdogs-sdl"
}

function install_cdogs-sdl() {
    md_ret_files=(        
        'src/cdogs-sdl'
        'src/cdogs-sdl-editor'
        'data'
        'doc'
        'dogfights'
        'graphics'
        'missions'
        'music'
        'sounds'
    )  
}

function configure_cdogs-sdl() {
    addPort "$md_id" "cdogs-sdl" "C-Dogs SDL" "$md_inst/cdogs-sdl --fullscreen"

    [[ "$md_mode" == "remove" ]] && return
    
    curl -sSL https://cxong.github.io/cdogs-sdl/missionpack.zip | bsdtar xvf - --strip-components=1 -C "$md_inst"

    isPlatform "dispmanx" && setBackend "$md_id" "dispmanx"

    moveConfigDir "$home/.config/cdogs-sdl" "$md_conf_root/cdogs-sdl"
}
