#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="smw"
rp_module_desc="Super Mario War - Fan-made Multiplayer Super Mario Bros. Style Deathmatch Game"
rp_module_licence="NONCOM"
rp_module_repo="git https://github.com/mmatyas/supermariowar.git master"
rp_module_section="opt"
rp_module_flags="sdl2 !mali"

function depends_smw() {
    getDepends cmake enet sdl2 sdl2_mixer sdl2_image
}

function sources_smw() {
    gitPullOrClone
}

function build_smw() {
    mkdir build
    cd build
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst"
    make clean
    make
    md_ret_require="$md_build/build/Binaries/Release/smw"
}

function install_smw() {
    cd build
    make install
}

function configure_smw() {
    addPort "$md_id" "smw" "Super Mario War" "$md_inst/smw"

    [[ "$md_mode" == "remove" ]] && return

    isPlatform "dispmanx" && setBackend "$md_id" "dispmanx"

    moveConfigFile "$home/.smw.options.bin" "$md_conf_root/smw/.smw.options.bin"
}
