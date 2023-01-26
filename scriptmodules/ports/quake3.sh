#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="quake3"
rp_module_desc="Quake 3: Quake 3 Arena Port"
rp_module_licence="GPL2 https://raw.githubusercontent.com/raspberrypi/quake3/master/COPYING.txt"
rp_module_repo="git https://github.com/raspberrypi/quake3 master"
rp_module_section="opt"
rp_module_flags="!all rpi"

function depends_quake3() {
    local depends=(
        'sdl12-compat'
        'raspberrypi-firmware'
    )
    getDepends "${depends[@]}"
}

function sources_quake3() {
    gitPullOrClone
}

function build_quake3() {
    ./build_rpi_raspbian.sh
    md_ret_require="${md_build}/build/release-linux-arm/ioquake3.arm"
}

function install_quake3() {
    md_ret_files=(
        'build/release-linux-arm/ioq3ded.arm'
        'build/release-linux-arm/ioquake3.arm'
    )
}

function _game_data_quake3() {
    local portname
    portname="quake3"

    if [[ ! -f "${romdir}/ports/${portname}/baseq3/pak0.pk3" ]] && [[ ! -f "${romdir}/ports/${portname}/demoq3/pak0.pk3" ]]; then
        downloadAndExtract "${__archive_url}/Q3DemoPaks.zip" "${romdir}/ports/${portname}/demoq3" -j
    fi
    chown -R "${user}:${user}" "${romdir}/ports/${portname}"
}

function configure_quake3() {
    local portname
    portname="quake3"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "ports/${portname}"
        _game_data_quake3
    fi

    moveConfigDir "${md_inst}/baseq3" "${romdir}/ports/${portname}/baseq3"

    addPort "${md_id}" "${portname}" "Quake III Arena" "LD_LIBRARY_PATH=lib ${md_inst}/ioquake3.arm"
}
