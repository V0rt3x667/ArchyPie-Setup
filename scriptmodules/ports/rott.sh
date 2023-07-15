#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="rott"
rp_module_desc="ROTT: Rise of the Triad Source Port"
rp_module_help="Copy Rise of the Triad Game Files To: ${romdir}/rott"
rp_module_licence="GPL2 https://raw.githubusercontent.com/fabiangreffrath/rott/main/COPYING"
rp_module_repo="git https://github.com/fabiangreffrath/rott main"
rp_module_section="exp"
rp_module_flags=""

function depends_rott() {
    local depends=(
        'sdl2_mixer'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_rott() {
    gitPullOrClone
}

function build_rott() {
    autoreconf -fiv
    ./configure --prefix="${md_inst}" --enable-datadir="${romdir}/ports/rott"
    make clean
    make
    md_ret_require="${md_build}/rott/rott"
}

function install_rott() {
    md_ret_files=(
        'doc'
        'rott/rott'
    )
}

function configure_rott() {
    mkRomDir "ports/rott"

    addPort "${md_id}" "${md_id}" "Rise of the Triad: Dark War" "${md_inst}/rott"
}
