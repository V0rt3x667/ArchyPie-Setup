#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-px68k"
rp_module_desc="Sharp X68000 Libretro Core"
rp_module_help="ROM Extensions: .2hd .88d .cmd .d88 .dim .dup .hdf .hdm .img .m3u .xdf .zip\n\nCopy X68000 Games To: ${romdir}/x68000\n\nCopy BIOS Files (cgrom.dat & iplrom.dat) To: ${biosdir}/x68000\n\nOPTIONAL: Copy BIOS Files (iplrom30.dat, iplromco.dat & iplromxv.dat) To: ${biosdir}/x68000"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/px68k-libretro/master/COPYING"
rp_module_repo="git https://github.com/libretro/px68k-libretro master"
rp_module_section="exp"
rp_module_flags=""

function sources_lr-px68k() {
    gitPullOrClone

    # Set BIOS Directory
    sed -e "s|sprintf(retro_system_conf, \"%s%ckeropi\", RETRO_DIR, SLASH);|sprintf(retro_system_conf, \"%s%cx68000\", RETRO_DIR, SLASH);|g" -i "${md_build}/libretro.c"
}

function build_lr-px68k() {
    make clean
    make
    md_ret_require="${md_build}/px68k_libretro.so"
}

function install_lr-px68k() {
    md_ret_files=('px68k_libretro.so')
}

function configure_lr-px68k() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "x68000"

        mkUserDir "${biosdir}/x68000"
    fi

    defaultRAConfig "x68000"

    addEmulator 1 "${md_id}" "x68000" "${md_inst}/px68k_libretro.so"

    addSystem "x68000"
}
