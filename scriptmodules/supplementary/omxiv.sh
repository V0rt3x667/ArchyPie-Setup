#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="omxiv"
rp_module_desc="OpenMAX Image Viewer for the Raspberry Pi"
rp_module_licence="GPL2 https://raw.githubusercontent.com/cmitu/omxiv/master/LICENSE"
rp_module_repo="git https://github.com/retropie/omxiv.git master"
rp_module_section="depends"
rp_module_flags="!all rpi"

function depends_omxiv() {
    getDepends raspberrypi-firmware libpng libjpeg
}

function sources_omxiv() {
    gitPullOrClone
}

function build_omxiv() {
    make clean
    make ilclient
    make
    md_ret_require="omxiv.bin"
}

function install_omxiv() {
    make install INSTALL="$md_inst"
}
