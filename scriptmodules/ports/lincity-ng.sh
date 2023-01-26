#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lincity-ng"
rp_module_desc="LinCity NG: A City Simulation Game"
rp_module_licence="GPL2 https://raw.githubusercontent.com/lincity-ng/lincity-ng/master/COPYING"
rp_module_repo="git https://github.com/lincity-ng/lincity-ng master"
rp_module_section="opt"
rp_module_flags="!mali"

function depends_lincity-ng() {
    local depends=(
        'ftjam'
        'libxml2'
        'physfs'
        'sdl2_gfx'
        'sdl2_image'
        'sdl2_mixer'
        'sdl2_ttf'
        'sdl2'
        'zlib'
    )
    getDepends "${depends[@]}"
}

function sources_lincity-ng() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|LC_SAVE_DIR \".lincity-ng\"|LC_SAVE_DIR \"ArchyPie/configs/${md_id}\"|g" -i "${md_build}/src/${md_id/-ng/}/loadsave.h"
}

function build_lincity-ng() {
    ./autogen.sh
    ./configure --prefix="${md_inst}"
    jam
    md_ret_require="${md_build}/${md_id}"
}

function install_lincity-ng() {
    jam -sprefix="${md_inst}" install
}

function configure_lincity-ng() {
    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    addPort "${md_id}" "${md_id}" "LinCity-NG" "${md_inst}/bin/${md_id} -g -f"
}
