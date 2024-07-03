#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="dbar4gun"
rp_module_desc="dbar4gun: A Linux User Space Driver For The Wiimote With DolphinBar Support"
rp_module_help="https://github.com/lowlevel-1989/dbar4gun"
rp_module_licence="MIT https://raw.githubusercontent.com/lowlevel-1989/dbar4gun/master/LICENSE"
rp_module_repo="git https://github.com/lowlevel-1989/dbar4gun master"
rp_module_section="driver"

function depends_dbar4gun() {
    local depends=(
        'python-setuptools'
        'python-virtualenv'
        'python'
    )
    getDepends "${depends[@]}"
}

function sources_dbar4gun() {
    gitPullOrClone
}

function install_dbar4gun() {
    virtualenv -p python "${md_inst}"
    source "${md_inst}/bin/activate"
    pip3 install .
    deactivate
}

function enable_dbar4gun() {
    local config="/etc/systemd/system/dbar4gun.service"

    disable_dbar4gun
    cat > "${config}" << _EOF_
[Unit]
Description=dbar4gun

[Service]
Type=simple
ExecStart=${md_inst}/bin/dbar4gun --width ${1} --height ${2}

[Install]
WantedBy=multi-user.target
_EOF_
    systemctl daemon-reload

    systemctl enable dbar4gun --now
    printMsgs "dialog" "dbar4gun enabled."
}

function disable_dbar4gun() {
    systemctl disable dbar4gun --now
}

function remove_dbar4gun() {
    disable_dbar4gun
    rm -rf "/etc/systemd/system/dbar4gun.service"
    systemctl daemon-reload
}

function gui_dbar4gun() {
    local cmd=(dialog --backtitle "${__backtitle}" --menu "Choose An Option" 22 86 16)
    local options=(
        1 "Enable/Restart dbar4gun (1080p)"
        2 "Enable/Restart dbar4gun (720p)"
        3 "Disable dbar4gun"
    )
    while true; do
        local choice
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "${choice}" ]]; then
            case "${choice}" in
                1)
                    enable_dbar4gun "1920" "1080"
                    ;;
                2)
                    enable_dbar4gun "1280" "720"
                    ;;
                3)
                    disable_dbar4gun
                    ;;
            esac
        else
            break
        fi
    done
}
