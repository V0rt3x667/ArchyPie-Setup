#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="giana"
rp_module_desc="Giana's Return - Unofficial Sequel to the Mario Clone Great Giana Sisters"
rp_module_licence="NONCOM https://www.gianas-return.de/?page_id=6"
rp_module_section="opt"
rp_module_flags="!all x86 videocore"

function depends_giana() {
    getDepends 'sdl' 'sdl_mixer'
}

function install_bin_giana() {
    if isPlatform "x86"; then
        downloadAndExtract "http://www.retroguru.com/gianas-return/gianas-return-v.latest-linux.tar.gz" "$md_inst" --strip-components 1
    else
        downloadAndExtract "http://www.retroguru.com/gianas-return/gianas-return-v.latest-raspberrypi.zip" "$md_inst" "$md_inst/giana_rpi"
    fi
}

function configure_giana() {
    moveConfigDir "$home/.giana" "$md_conf_root/giana"

    if isPlatform "x86 64bit"; then
        addPort "$md_id" "giana" "Giana's Return" "pushd $md_inst; $md_inst/giana_linux64 -fs -a44; popd"
    elif isPlatform "x86 32bit"; then
        addPort "$md_id" "giana" "Giana's Return" "pushd $md_inst; $md_inst/giana_linux32 -fs -a44; popd"
    else
        addPort "$md_id" "giana" "Giana's Return" "pushd $md_inst; $md_inst/giana_rpi; popd"
        chmod +x "$md_inst/giana_rpi"
    fi
}
