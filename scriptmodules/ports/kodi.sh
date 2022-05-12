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
    # to show as installed in archypie-setup
    hasPackage kodi && mkdir -p "$md_inst"
}

function depends_kodi() {
    addUdevInputRules
}

function install_bin_kodi() {
    # force pacmanInstall to get a fresh list before installing
    __pacman_update=0

    pacmanInstall kodi kodi-platform p8-platform
}

function remove_kodi() {
    pacmanRemove kodi kodi-platform p8-platform
    rp_callModule kodi depends remove
}

function configure_kodi() {
    moveConfigDir "$home/.kodi" "$md_conf_root/kodi"

    addPort "$md_id" "kodi" "Kodi" "kodi-standalone"
}
