#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="emulationstation-dev"
rp_module_desc="EmulationStation (Latest Development Version) - Frontend Used by ArchyPie for Launching Emulators"
rp_module_licence="MIT https://raw.githubusercontent.com/RetroPie/EmulationStation/master/LICENSE.md"
rp_module_repo="git https://github.com/RetroPie/EmulationStation master"
rp_module_section="exp"
rp_module_flags="frontend"

function _update_hook_emulationstation-dev() {
    _update_hook_emulationstation
}

function depends_emulationstation-dev() {
    depends_emulationstation
}

function sources_emulationstation-dev() {
    sources_emulationstation
}

function build_emulationstation-dev() {
    build_emulationstation
}

function install_emulationstation-dev() {
    install_emulationstation
}

function configure_emulationstation-dev() {
    rp_callModule "emulationstation" remove
    configure_emulationstation
}

function remove_emulationstation-dev() {
    remove_emulationstation
}

function gui_emulationstation-dev() {
    gui_emulationstation
}
