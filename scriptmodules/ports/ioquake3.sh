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
    make
    md_ret_require="$md_build/build/release-linux-$(_arch_ioquake3)/ioquake3.$(_arch_ioquake3)"
}

function _arch_ioquake3() {
    # exact parsing from Makefile
    echo "$(uname -m | sed -e 's/i.86/x86/' | sed -e 's/^arm.*/arm/')"
}

function install_ioquake3() {
    md_ret_files=(
        "build/release-linux-$(_arch_ioquake3)/ioq3ded.$(_arch_ioquake3)"
        "build/release-linux-$(_arch_ioquake3)/ioquake3.$(_arch_ioquake3)"
        "build/release-linux-$(_arch_ioquake3)/renderer_opengl1_$(_arch_ioquake3).so"
        "build/release-linux-$(_arch_ioquake3)/renderer_opengl2_$(_arch_ioquake3).so"
    )
}

function configure_ioquake3() {
    local launcher
    isPlatform "mesa" && launcher+=("+set cl_renderer opengl1")
    isPlatform "kms" && launcher+=("+set r_mode -1" "+set r_customwidth %XRES%" "+set r_customheight %YRES%" "+set r_swapInterval 1")

    addPort "$md_id" "quake3" "Quake III Arena" "$md_inst/ioquake3.$(_arch_ioquake3) ${launcher[*]}"
    addPort "$md_id" "quake3" "Quake III Team Arena" "$md_inst/ioq3ded.$(_arch_ioquake3) ${launcher[*]}"

    mkRomDir "ports/quake3"

    moveConfigDir "$md_inst/baseq3" "$romdir/ports/quake3"
    moveConfigDir "$home/.q3a" "$md_conf_root/ioquake3"

    [[ "$md_mode" == "install" ]] && game_data_quake3
}
