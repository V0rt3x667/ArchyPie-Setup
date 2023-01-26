#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-mess2016"
rp_module_desc="MESS 2016 Libretro Core"
rp_module_help="See wiki for detailed explanation"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/mame2016-libretro/master/LICENSE.md"
rp_module_repo="git https://github.com/libretro/mame2016-libretro master"
rp_module_section="exp"
rp_module_flags=""

function depends_lr-mess2016() {
    depends_lr-mame2016
}

function sources_lr-mess2016() {
    gitPullOrClone
}

function build_lr-mess2016() {
    rpSwap on 1200
    local params=($(_get_params_lr-mame) SUBTARGET=mess)
    make clean
    make "${params[@]}"
    rpSwap off
    md_ret_require="$md_build/mess2016_libretro.so"
}

function install_lr-mess2016() {
    md_ret_files=(
        'mess2016_libretro.so'
    )
}

function configure_lr-mess2016() {
    configure_lr-mess "mess2016_libretro.so"
}
