#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-fceumm"
rp_module_desc="Nintendo NES & Famicom Libretro Core"
rp_module_help="ROM Extensions: .fds .nes .unf .unif .zip\n\nCopy NES ROMs To: ${romdir}/nes\n\nCopy Famicom Disk System Games To: ${romdir}/fds\n\nCopy Famicom Disk System BIOS File (disksys.rom} To: ${biosdir}/fds"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/libretro-fceumm/master/Copying"
rp_module_repo="git https://github.com/libretro/libretro-fceumm master"
rp_module_section="main"

function sources_lr-fceumm() {
    gitPullOrClone
}

function build_lr-fceumm() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro

    md_ret_require="${md_build}/fceumm_libretro.so"
}

function install_lr-fceumm() {
    md_ret_files=('fceumm_libretro.so')
}

function configure_lr-fceumm() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "fds"
        mkRomDir "nes"

        mkUserDir "${biosdir}/fds"
    fi

    defaultRAConfig "fds" "system_directory" "${biosdir}/fds"
    defaultRAConfig "nes"

    addEmulator 0 "${md_id}" "fds" "${md_inst}/fceumm_libretro.so"
    addEmulator 1 "${md_id}" "nes" "${md_inst}/fceumm_libretro.so"

    addSystem "fds"
    addSystem "nes"
}
