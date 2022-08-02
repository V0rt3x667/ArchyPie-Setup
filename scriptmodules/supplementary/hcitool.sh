#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="bluez-hcitool"
rp_module_desc="BlueZ-hcitool - Deprecated Tool Required by ArchyPie Bluetooth Module"
rp_module_licence="GPL2 https://raw.githubusercontent.com/bluez/bluez/master/COPYING"
rp_module_repo="git https://github.com/bluez/bluez 5.63"
rp_module_section="depends"
rp_module_flags=""

function depends_bluez-hcitool() {
    getDepends bluez
}

function sources_bluez-hcitool() {
    gitPullOrClone
}

function build_bluez-hcitool() {
    cd tools
    gcc hcitool.c ../src/oui.c -lbluetooth -o hcitool -DVERSION="5.63" -I..
    md_ret_require=('hcitool')
}

function install_bluez-hcitool() {
    md_ret_files=('tools/hcitool')
}
