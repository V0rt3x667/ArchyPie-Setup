#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-2048"
rp_module_desc="2048 Libretro Core"
rp_module_help="https://github.com/libretro/libretro-2048"
rp_module_licence="The Unlicense https://raw.githubusercontent.com/libretro/libretro-2048/master/COPYING"
rp_module_repo="git https://github.com/libretro/libretro-2048 master"
rp_module_section="opt"

function sources_lr-2048() {
    gitPullOrClone
}

function build_lr-2048() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro
    md_ret_require="$md_build/2048_libretro.so"
}

function install_lr-2048() {
    md_ret_files=('2048_libretro.so')
}

function configure_lr-2048() {
    setConfigRoot "ports"

    addPort "$md_id" "2048" "2048" "$md_inst/2048_libretro.so"

    defaultRAConfig "2048"
}
