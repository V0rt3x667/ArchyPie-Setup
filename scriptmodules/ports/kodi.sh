#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution

rp_module_id="kodi"
rp_module_desc="Kodi - Open Source Home Theatre Software"
rp_module_licence="GPL2 https://raw.githubusercontent.com/xbmc/xbmc/master/LICENSE.md"
rp_module_section="opt"
rp_module_flags="!mali"

function _update_hook_kodi() {
    # Show as Installed in ArchyPie-Setup
    hasPackage kodi && mkdir -p "$md_inst"
}

function depends_kodi() {
    addUdevInputRules
}

function install_bin_kodi() {
    pacmanInstall kodi kodi-eventclients kodi-platform p8-platform
}

function remove_kodi() {
    pacmanRemove kodi kodi-eventclients kodi-platform p8-platform
    rp_callModule kodi depends remove
}

function configure_kodi() {
    moveConfigDir "$home/.kodi" "$md_conf_root/kodi"

    addPort "$md_id" "kodi" "Kodi" "kodi-standalone"
}
