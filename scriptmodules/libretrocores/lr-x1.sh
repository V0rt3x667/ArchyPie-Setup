#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-x1"
rp_module_desc="Sharp X1 Libretro Core"
rp_module_help="ROM Extensions: .2d .2hd .88d .cmd .d88 .dup .dx1 .hdm .tap .tfd .xdf .zip .zip\n\nCopy X1 ROMs To: ${romdir}/x1\n\nCopy BIOS Files: IPLROM.X1 & IPLROM.X1T To: ${biosdir}/x1"
rp_module_licence="BSD https://raw.githubusercontent.com/libretro/xmil-libretro/master/LICENSE"
rp_module_repo="git https://github.com/libretro/xmil-libretro master"
rp_module_section="exp"

function sources_lr-x1() {
    gitPullOrClone

    # Remove Hardcoded BIOS Directory
    sed -e "s|\"%s%cxmil\\\0\",RETRO_DIR,slash|\"%s\",RETRO_DIR|g" -i "${md_build}/libretro/libretro.c"

    # Prevent Temp Files From Being Created In The Current Directory
    sed -e "s|curpath\[MAX_PATH\] = \"./\";|curpath\[MAX_PATH\] = \"${md_inst}\";|g" -i "${md_build}/libretro/dosio.c"
}

function build_lr-x1() {
    make -C libretro -f Makefile.libretro clean
    make -C libretro -f Makefile.libretro
    md_ret_require="${md_build}/libretro/x1_libretro.so"
}

function install_lr-x1() {
    md_ret_files=('libretro/x1_libretro.so')
}

function configure_lr-x1() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "x1"
        mkUserDir "${biosdir}/x1"
        defaultRAConfig "x1"
    fi

    addEmulator 1 "${md_id}" "x1" "${md_inst}/x1_libretro.so"

    addSystem "x1"
}
