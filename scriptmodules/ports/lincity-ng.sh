#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lincity-ng"
rp_module_desc="LinCity NG - Open-source City Building Game"
rp_module_licence="GPL2 https://raw.githubusercontent.com/lincity-ng/lincity-ng/master/COPYING"
rp_module_repo="git https://github.com/lincity-ng/lincity-ng.git master"
rp_module_section="opt"
rp_module_flags="!mali"

function depends_lincity-ng() {
    local depends=(
        'ftjam'
        'glu'
        'libglvnd'
        'mesa'
        'physfs'
        'sdl2_gfx'
        'sdl2_image'
        'sdl2_mixer'
        'sdl2_ttf'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_lincity-ng() {
    gitPullOrClone
}

function build_lincity-ng() {
    ./autogen.sh
    ./configure --prefix="$md_inst"
    jam
    md_ret_require="$md_build/lincity-ng"
}

function install_lincity-ng() {
    jam -sprefix="$md_inst" install
}

function configure_lincity-ng() {
    local binary="XINIT:$md_inst/bin/lincity-ng -g -f"

    addPort "$md_id" "lincity-ng" "LinCity-NG" "$binary"

    moveConfigDir "$home/.lincity-ng" "$md_conf_root/lincity-ng"
    # fix for wrong config location
    if [[ -d "/lincity-ng" ]]; then
        cp -R /lincity-ng "$md_conf_root/"
        rm -rf /lincity-ng
        chown "$user:$user" "$md_conf_root/lincity-ng"
    fi
}
