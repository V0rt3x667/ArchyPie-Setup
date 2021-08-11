#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="ppsspp-1.5.4"
rp_module_desc="PPSSPP v1.5.4 - Sony PlayStation Portable Emulator"
rp_module_help="ROM Extensions: .iso .pbp .cso\n\nCopy your PlayStation Portable roms to $romdir/psp"
rp_module_licence="GPL2 https://raw.githubusercontent.com/hrydgard/ppsspp/master/LICENSE.TXT"
rp_module_repo="git https://github.com/hrydgard/ppsspp.git v1.5.4"
rp_module_section="opt"
rp_module_flags="!all videocore"

function depends_ppsspp-1.5.4() {
    depends_ppsspp
}

function sources_ppsspp-1.5.4() {
    sources_ppsspp
}

function build_ppsspp-1.5.4() {
    build_ppsspp
}

function install_ppsspp-1.5.4() {
    install_ppsspp
}

function configure_ppsspp-1.5.4() {
    configure_ppsspp
}
