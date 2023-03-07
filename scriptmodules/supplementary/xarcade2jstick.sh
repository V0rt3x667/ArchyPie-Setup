#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="xarcade2jstick"
rp_module_desc="Xarcade2Jstick: User Space Driver To Map The X-Arcade Tankstick To Two Virtual Game Pads"
rp_module_licence="GPL3 https://raw.githubusercontent.com/petrockblog/Xarcade2Jstick/master/gpl3.txt"
rp_module_repo="git https://github.com/petrockblog/Xarcade2Joystick.git master"
rp_module_section="driver"
rp_module_flags="noinstclean"

function sources_xarcade2jstick() {
    gitPullOrClone "${md_inst}"

    # Fix Installation Location
    sed -e "s|prefix[[:blank:]]*= /usr/local|prefix = /usr|g" -i "${md_inst}/Makefile"
}

function build_xarcade2jstick() {
    make -C "${md_inst}" clean
    make -C "${md_inst}"

}

function install_xarcade2jstick() {
    make -C "${md_inst}" install
}


function enable_xarcade2jstick() {
    make -C "${md_inst}" installservice
}

function disable_xarcade2jstick() {
    make -C "${md_inst}" uninstallservice
}

function remove_xarcade2jstick() {
    [[ -f "/lib/systemd/system/xarcade2jstick.service" ]] && disable_xarcade2jstick
    make -C "${md_inst}" uninstall
}

function gui_xarcade2jstick() {
    local status
    local options=(
        1 "Enable Xarcade2Jstick Service"
        2 "Disable Xarcade2Jstick Service"
    )
    while true; do
        status="Disabled"
        [[ -f "/lib/systemd/system/xarcade2jstick.service" ]] && status="Enabled"
        local cmd=(dialog --backtitle "${__backtitle}" --menu "Service Is Currently: ${status}" 22 86 16)
        local choice
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "${choice}" ]] && break
        case "${choice}" in
            1)
                enable_xarcade2jstick
                printMsgs "dialog" "Enabled Xarcade2Jstick Service"
                ;;
            2)
                disable_xarcade2jstick
                printMsgs "dialog" "Disabled Xarcade2Jstick Service"
                ;;
        esac
    done
}
