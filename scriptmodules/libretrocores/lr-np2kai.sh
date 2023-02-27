#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-np2kai"
rp_module_desc="NEC PC-9800 Libretro Core"
rp_module_help="ROM Extensions: .2hd .88d .98d .cmd .d88 .d98 .dup .fdd .fdi .hdd .hdi .hdm .hdn .nhd .tfd .thd .xdf .zip\n\nCopy PC-98 Games To: ${romdir}/pc98\n\nCopy BIOS Files:\n\n2608_bd.wav\n2608_hh.wav\n2608_rim.wav\n2608_sd.wav\n2608_tom.wav\n2608_top.wav\nbios.rom\nFONT.ROM\sound.rom\n\nTo: ${biosdir}/pc98"
rp_module_licence="MIT https://raw.githubusercontent.com/libretro/NP2kai/master/LICENSE"
rp_module_repo="git https://github.com/AZO234/NP2kai master"
rp_module_section="exp"

function sources_lr-np2kai() {
    gitPullOrClone

    # Set BIOS Directory
    sed -e "s|milstr_ncat(np2path, OEMTEXT(\"/np2kai\"), MAX_PATH);|milstr_ncat(np2path, OEMTEXT(\"/pc98\"), MAX_PATH);|g" -i "${md_build}/sdl/libretro/libretro.c"
}

function build_lr-np2kai() {
    make -C sdl -f Makefile.libretro clean GIT_TAG="master"
    make -C sdl -f Makefile.libretro GIT_TAG="master"
    md_ret_require="${md_build}/sdl/np2kai_libretro.so"
}

function install_lr-np2kai() {
    md_ret_files=('sdl/np2kai_libretro.so')
}

function configure_lr-np2kai() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "pc98"

        mkUserDir "${biosdir}/pc98"
    fi

    defaultRAConfig "pc98"

    addEmulator 1 "${md_id}" "pc98" "${md_inst}/np2kai_libretro.so"

    addSystem "pc98"
}
