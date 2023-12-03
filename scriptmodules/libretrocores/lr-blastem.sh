#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-blastem"
rp_module_desc="Sega Mega Drive (Genesis) Libretro Core"
rp_module_help="ROM Extensions: .68k .bin .gen .md .sgd .smd\n\nCopy Sega Mega Drive (Genesis) ROMs To Either: ${romdir}/megadrive\n${romdir}/genesis"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/blastem/master/COPYING"
rp_module_repo="git https://github.com/libretro/blastem libretro"
rp_module_section="opt"

function sources_lr-blastem() {
    gitPullOrClone
}

function build_lr-blastem() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro
    md_ret_require="${md_build}/blastem_libretro.so"
}

function install_lr-blastem() {
    md_ret_files=('blastem_libretro.so')
}

function configure_lr-blastem() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "megadrive"
        defaultRAConfig "megadrive"
    fi

    addEmulator 0 "${md_id}" "megadrive" "${md_inst}/blastem_libretro.so"

    addSystem "megadrive"
}
