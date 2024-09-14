#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-xrick"
rp_module_desc="Rick Dangerous Libretro Core"
rp_module_licence="GPL https://raw.githubusercontent.com/libretro/xrick-libretro/master/README"
rp_module_repo="git https://github.com/libretro/xrick-libretro master"
rp_module_section="opt"

function sources_lr-xrick() {
    gitPullOrClone
}

function build_lr-xrick() {
    make clean
    make
    md_ret_require="${md_build}/xrick_libretro.so"
}

function install_lr-xrick() {
    md_ret_files=('xrick_libretro.so')
}

function _add_data_lr-xrick() { 
    if [[ ! -f "${biosdir}/xrick/data.zip" ]]; then
        mkUserDir "${biosdir}/xrick"
        curl -sSL "https://buildbot.libretro.com/assets/cores/Rick%20Dangerous/Rick%20Dangerous.zip" | bsdtar xvf - --strip-components=1 -C "${biosdir}/xrick"
        chown -R "${__user}":"${__group}" "${biosdir}/xrick/data.zip"
    fi
}

function configure_lr-xrick() {
    if [[ "${md_mode}" == "install" ]]; then
        setConfigRoot "ports"
        defaultRAConfig "xrick"
        _add_data_lr-xrick
    fi

    addPort "${md_id}" "xrick" "Rick Dangerous" "${md_inst}/xrick_libretro.so" "${biosdir}/xrick/data.zip"
}
