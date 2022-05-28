#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="bombermaaan"
rp_module_desc="Bombermaaan - Bomberman Clone"
rp_module_licence="GPL3 https://raw.githubusercontent.com/bjaraujo/Bombermaaan/master/LICENSE.txt"
rp_module_repo="git https://github.com/bjaraujo/Bombermaaan.git master"
rp_module_section="exp"
rp_module_flags="sdl1 !mali"

function depends_bombermaaan() {
    local depends=(
        'cmake'
        'ninja'
        'sdl_gfx'
        'sdl_mixer'
    )
    getDepends "${depends[@]}"
}

function sources_bombermaaan() {
    gitPullOrClone
    # "sdl 1 classic" required, Bombermaaan will not build with sdl12-compat.
    _sources_sdl
}

function _sources_sdl() {
    gitPullOrClone "$md_build/sdl" "https://github.com/libsdl-org/SDL-1.2.git" "main"
}

function _build_sdl() {
    cd sdl || return
    ./autogen.sh
    ./configure --disable-rpath --disable-static
    make clean
    make
}

function build_bombermaaan() {
    _build_sdl && cd "$md_build" || return
    cmake . \
        -Strunk \
        -Btrunk/build \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN=ON \
        -DSDLMAIN_LIBRARY="$md_build/sdl/build/.libs/libSDLmain.a" \
        -DSDL_LIBRARY="$md_build/sdl/build/.libs/libSDL.so" \
        -DSDL_INCLUDE_DIR="$md_build/sdl/include" \
        -DLOAD_RESOURCES_FROM_FILES=ON \
        -Wno-dev
    ninja -C trunk/build clean
    ninja -C trunk/build
    md_ret_require="$md_build/trunk/build/bin/Bombermaaan"
}

function install_bombermaaan() {
    # md_ret_files=(        
    #     'trunk/bombermaaan'
    #     'trunk/levels'
    #     'trunk/res/images'
    #     'trunk/res/sounds'
    # )
    ninja -C trunk/build install/strip
}

function configure_bombermaaan() {
    addPort "$md_id" "bombermaaan" "Bombermaaan" "$md_inst/Bombermaaan"

    isPlatform "dispmanx" && setBackend "$md_id" "dispmanx"

    moveConfigDir "$home/.Bombermaaan" "$md_conf_root/bombermaaan"
    moveConfigFile "$md_inst/config.xml" "$md_conf_root/bombermaaan/config.xml"

#     local file="$romdir/ports/Bombermaaan.sh"
#     cat >"$file" << _EOF_
# #!/bin/bash
# pushd "$md_inst"
# "$rootdir/supplementary/runcommand/runcommand.sh" 0 _PORT_ bombermaaan ""
# popd
# _EOF_
#     chown $user:$user "$file"
#     chmod a+x "$file"
}
