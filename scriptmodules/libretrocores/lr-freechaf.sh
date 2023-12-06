#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-freechaf"
rp_module_desc="Fairchild ChannelF Libretro Core"
rp_module_help="ROM Extensions: .bin .rom\n\nCopy ChannelF ROMs To: ${romdir}/channelf\n\nCopy BIOS Files: sl31245.bin & sl31253.bin Or sl90025.bin To: ${biosdir}/channelf"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/FreeChaF/master/LICENSE"
rp_module_repo="git https://github.com/libretro/FreeChaF master"
rp_module_section="exp"

function sources_lr-freechaf() {
    gitPullOrClone
}

function build_lr-freechaf() {
    make clean
    make
    md_ret_require="${md_build}/freechaf_libretro.so"
}

function install_lr-freechaf() {
    md_ret_files=('freechaf_libretro.so')
}

function configure_lr-freechaf() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "channelf"
        mkUserDir "${biosdir}/channelf"
        defaultRAConfig "channelf"
    fi

    addEmulator 1 "${md_id}" "channelf" "${md_inst}/freechaf_libretro.so"

    addSystem "channelf"
}
