#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="virtualgamepad"
rp_module_desc="Node Virtual Gamepads: Turns Your Smartphone Into A Virtual Gamepad"
rp_module_licence="MIT https://raw.githubusercontent.com/miroof/node-virtual-gamepads/master/LICENSE"
rp_module_repo="git https://github.com/miroof/node-virtual-gamepads.git master"
rp_module_section="exp"
rp_module_flags="nobin noinstclean"

function depends_virtualgamepad() {
    local depends=(
        'nodejs'
        'npm'
    )
    getDepends "${depends[@]}"
}

function remove_virtualgamepad() {
    pm2 stop main
    pm2 delete main
}

function sources_virtualgamepad() {
    gitPullOrClone "${md_inst}"
    chown -R "${__user}":"${__group}" "${md_inst}"
}

function install_virtualgamepad() {
    npm install pm2 -g --unsafe-perm
    cd "${md_inst}" || exit
    sudo -u "${__user}" npm install
    sudo -u "${__user}" npm install ref
}

function configure_virtualgamepad() {
    [[ "${md_mode}" == "remove" ]] && return
    pm2 start main.js
    pm2 startup
    pm2 save
}
