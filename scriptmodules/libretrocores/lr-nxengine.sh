#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="lr-nxengine"
rp_module_desc="NxEngine (Cave Story Engine) Libretro Core"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/nxengine-libretro/master/nxengine/LICENSE"
rp_module_repo="git https://github.com/libretro/nxengine-libretro master"
rp_module_section="opt"

function sources_lr-nxengine() {
    gitPullOrClone
}

function build_lr-nxengine() {
    make clean
    make
    md_ret_require="${md_build}/nxengine_libretro.so"
}

function install_lr-nxengine() {
    md_ret_files=('nxengine_libretro.so')
}

function _add_data_lr-nxengine() { 
    if [[ ! -f "${romdir}/ports/cavestory/Doukutsu.exe" ]]; then
        mkRomDir "ports/cavestory"
        curl -sSL "http://buildbot.libretro.com/assets/system/NXEngine%20%28Cave%20Story%29.zip" | bsdtar xvf - --strip-components=1 -C "${romdir}/ports/cavestory"
        chown -R "${user}:${user}" "${romdir}/ports/cavestory/Doukutsu.exe"
    fi
}

function configure_lr-nxengine() {
    if [[ "${md_mode}" == "install" ]]; then
        _add_data_lr-nxengine
        setConfigRoot "ports"
        defaultRAConfig "cavestory"
    fi

    addPort "${md_id}" "cavestory" "Cave Story" "${md_inst}/nxengine_libretro.so ${romdir}/ports/cavestory/Doukutsu.exe"
}
