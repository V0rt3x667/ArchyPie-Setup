#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="giana"
rp_module_desc="Giana's Return: Unofficial Sequel to the Mario Clone Great Giana Sisters"
rp_module_licence="NONCOM https://www.gianas-return.de/?page_id=6"
rp_module_section="opt"
rp_module_flags="!all rpi x86"

function depends_giana() {
    local depends=(
        'sdl_mixer'
        'sdl12-compat'
    )
    getDepends "${depends[@]}"
}

function install_bin_giana() {
    if isPlatform "x86"; then
        downloadAndExtract "http://www.retroguru.com/gianas-return/gianas-return-v.latest-linux.tar.gz" "${md_inst}" --strip-components 1
    else
        downloadAndExtract "http://www.retroguru.com/gianas-return/gianas-return-v.latest-raspberrypi.zip" "${md_inst}"
    fi
}

function configure_giana() {
    moveConfigDir "${home}/.giana" "${md_conf_root}/${md_id}"

    if isPlatform "x86" && isPlatform "64bit"; then
        addPort "${md_id}" "${md_id}" "Giana's Return" "pushd ${md_inst}; ${md_inst}/${md_id}_linux64 -fs -a44; popd"
    elif isPlatform "x86" && isPlatform "32bit"; then
        addPort "${md_id}" "${md_id}" "Giana's Return" "pushd ${md_inst}; ${md_inst}/${md_id}_linux32 -fs -a44; popd"
    else
        addPort "${md_id}" "${md_id}" "Giana's Return" "pushd ${md_inst}; ${md_inst}/${md_id}_rpi; popd"
        chmod +x "${md_inst}/giana_rpi"
    fi
}
