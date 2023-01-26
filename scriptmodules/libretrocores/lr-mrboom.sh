#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-mrboom"
rp_module_desc="Mr.Boom Libretro Core"
rp_module_help="8 Players Bomberman Clone"
rp_module_licence="MIT https://raw.githubusercontent.com/libretro/mrboom-libretro/master/LICENSE"
rp_module_repo="git https://github.com/libretro/mrboom-libretro master"
rp_module_section="opt"

function sources_lr-mrboom() {
    gitPullOrClone
}

function build_lr-mrboom() {
    rpSwap on 1000
    make clean
    if isPlatform "neon"; then
        make HAVE_NEON=1
    else
        make
    fi
    md_ret_require="$md_build/mrboom_libretro.so"
}

function install_lr-mrboom() {
    md_ret_files=(
        'mrboom_libretro.so'
        'LICENSE'
        'README.md'
    )
}


function configure_lr-mrboom() {
    setConfigRoot "ports"

    addPort "$md_id" "mrboom" "Mr.Boom" "$emudir/retroarch/bin/retroarch -L $md_inst/mrboom_libretro.so --config $md_conf_root/mrboom/retroarch.cfg"

    defaultRAConfig "mrboom"
}
