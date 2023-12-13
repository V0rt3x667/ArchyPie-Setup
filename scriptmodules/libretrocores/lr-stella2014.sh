#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-stella2014"
rp_module_desc="Atari 2600 Libretro Core"
rp_module_help="ROM Extensions: .a26 .bin .zip\n\nCopy Atari 2600 ROMs To: ${romdir}/atari2600"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/stella2014-libretro/master/stella/license.txt"
rp_module_repo="git https://github.com/libretro/stella2014-libretro master"
rp_module_section="opt"

function sources_lr-stella2014() {
    gitPullOrClone
}

function build_lr-stella2014() {
    make clean
    make
    md_ret_require="${md_build}/stella2014_libretro.so"
}

function install_lr-stella2014() {
    md_ret_files=('stella2014_libretro.so')
}

function configure_lr-stella2014() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "atari2600"
        defaultRAConfig "atari2600"
    fi

    addEmulator 0 "${md_id}" "atari2600" "${md_inst}/stella2014_libretro.so"

    addSystem "atari2600"
}
