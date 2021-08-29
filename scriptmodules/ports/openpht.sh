#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="openpht"
rp_module_desc="OpenPHT - Community Driven Fork of Plex Home Theater"
rp_module_licence="GPL2 https://raw.githubusercontent.com/RasPlex/OpenPHT/openpht-1.9/copying.txt"
rp_module_section="exp"
rp_module_flags="!arm"

function depends_openpht() {
    addUdevInputRules
}

function install_bin_openpht() {
    pacmanPkg archy-openpht
}

function remove_openpht() {
    pacmanRemove archy-openpht
}

function configure_openpht() {
    addPort "$md_id" "$md_id" "OpenPHT" "pasuspender -- env AE_SINK=ALSA openpht"
}
