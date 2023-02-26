#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE.md file at the top-level directory of this distribution.

rp_module_id="lr-melonds"
rp_module_desc="Nintendo DS Libretro Core"
rp_module_help="ROM Extensions: .dsi .nds .zip\n\nCopy NDS ROMs To: ${romdir}/nds\n\nCopy BIOS Files:\n\nbios7.bin\nbios9.bin\nfirmware.bin\n\nTo: ${biosdir}/nds"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/melonDS/master/LICENSE"
rp_module_repo="git https://github.com/libretro/melonDS master"
rp_module_section="opt"

function depends_lr-melonds() {
    getDepends libslirp
}

function sources_lr-melonds() {
    gitPullOrClone
}

function build_lr-melonds() {
    make clean
    make
    md_ret_require="${md_build}/melonds_libretro.so"
}

function install_lr-melonds() {
    md_ret_files=('melonds_libretro.so')
}

function configure_lr-melonds() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "nds"

        mkUserDir "${biosdir}/nds"
    fi

    defaultRAConfig "nds" "system_directory" "${biosdir}/nds"

    addEmulator 0 "${md_id}" "nds" "${md_inst}/melonds_libretro.so"

    addSystem "nds"
}
