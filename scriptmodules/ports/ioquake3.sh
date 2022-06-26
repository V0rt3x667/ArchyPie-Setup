#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="ioquake3"
rp_module_desc="ioquake3 - Quake 3 Arena Port"
rp_module_licence="GPL2 https://github.com/ioquake/ioq3/blob/master/COPYING.txt"
rp_module_repo="git https://github.com/ioquake/ioq3.git main"
rp_module_section="opt"
rp_module_flags="!videocore"

function depends_ioquake3() {
    getDepends sdl2 mesa
}

function sources_ioquake3() {
    gitPullOrClone
}

function build_ioquake3() {
    make clean
    make COPYDIR="$md_inst" USE_INTERNAL_LIBS=0
    md_ret_require="$md_build/build/release-linux-$(_arch_ioquake3)/ioquake3.$(_arch_ioquake3)"
}

function _arch_ioquake3() {
    uname -m | sed -e 's/i.86/x86/' | sed -e 's/^arm.*/arm/'
}

function install_ioquake3() {
    make COPYDIR="$md_inst" USE_INTERNAL_LIBS=0 copyfiles
}

function configure_ioquake3() {
    local launcher
    isPlatform "mesa" && launcher+=("+set cl_renderer opengl1")
    isPlatform "kms" && launcher+=("+set r_mode -1" "+set r_customwidth %XRES%" "+set r_customheight %YRES%" "+set r_swapInterval 1")
    isPlatform "x11" && launcher+=("+set r_mode -2" "+set r_fullscreen 1")

    addPort "$md_id" "quake3" "Quake III Arena" "$md_inst/ioquake3.$(_arch_ioquake3) ${launcher[*]}"
    addPort "$md_id" "quake3-ta" "Quake III Team Arena" "$md_inst/ioquake3.$(_arch_ioquake3) +set fs_game missionpack ${launcher[*]}"
    
    mkRomDir "ports/quake3"

    moveConfigDir "$md_inst/baseq3" "$romdir/ports/quake3/baseq3"
    moveConfigDir "$md_inst/missionpack" "$romdir/ports/quake3/missionpack"
    moveConfigDir "$home/.q3a" "$md_conf_root/ioquake3"

    [[ "$md_mode" == "install" ]] && game_data_quake3
}
