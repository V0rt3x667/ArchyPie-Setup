#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="micropolis"
rp_module_desc="Micropolis - Open Source City Building Game"
rp_module_licence="GPL3 https://www.donhopkins.com/home/micropolis/#license"
rp_module_repo="git https://git.zerfleddert.de/git/micropolis"
rp_module_section="opt"
rp_module_flags="!all x11"

function depends_micropolis() {
    local depends=(
        'inetutils'
        'libxpm'
        'sdl_mixer'
        'sdl12-compat'
    )
    getDepends "${depends[@]}"
}

function sources_micropolis() {
    gitPullOrClone
}

function build_micropolis() {
    make clean
    make -C src
    make PREFIX="$md_inst"
    md_ret_require="$md_build/src/sim/sim"
}

function install_micropolis() {
    make PREFIX="$md_inst" install
}

function configure_micropolis() {
    addPort "$md_id" "micropolis" "$md_inst/bin/micropolis"
}
