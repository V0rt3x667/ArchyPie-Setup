#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution

rp_module_id="kodi"
rp_module_desc="Kodi: Open Source Home Theatre Software"
rp_module_licence="GPL2 https://raw.githubusercontent.com/xbmc/xbmc/master/LICENSE.md"
rp_module_section="opt"
rp_module_flags=""

function _update_hook_kodi() {
    # Show As Installed In ArchyPie-Setup
    hasPackage kodi && mkdir -p "${md_inst}"
}

function depends_kodi() {
    addUdevInputRules
}

function install_bin_kodi() {
    local packages=(
        'kodi-addon-inputstream-adaptive'
        'kodi-addon-inputstream-rtmp'
        'kodi-addon-peripheral-joystick'
        'kodi-eventclients'
        'kodi-platform'
        'kodi'
        'p8-platform'
    )
    pacmanInstall "${packages[@]}"
}

function remove_kodi() {
    local packages=(
        'kodi-addon-inputstream-adaptive'
        'kodi-addon-inputstream-rtmp'
        'kodi-addon-peripheral-joystick'
        'kodi-eventclients'
        'kodi-platform'
        'kodi'
        'p8-platform'
    )
    pacmanRemove "${packages[@]}"
    rp_callModule kodi depends remove
}

function configure_kodi() {
    moveConfigDir "${home}/.kodi" "${md_conf_root}/${md_id}"

    addPort "${md_id}" "${md_id}" "Kodi" "kodi-standalone"
}
