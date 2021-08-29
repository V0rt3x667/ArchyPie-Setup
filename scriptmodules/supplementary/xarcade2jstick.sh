#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="xarcade2jstick"
rp_module_desc="Xarcade2Jstick"
rp_module_licence="GPL3 https://raw.githubusercontent.com/petrockblog/Xarcade2Jstick/master/gpl3.txt"
rp_module_repo="git https://github.com/petrockblog/Xarcade2Joystick.git master"
rp_module_section="driver"
rp_module_flags="noinstclean"

function sources_xarcade2jstick() {
    gitPullOrClone "$md_inst"
}

function build_xarcade2jstick() {
    cd "$md_inst"
    make
}

function install_xarcade2jstick() {
    cd "$md_inst"
    make install
}


function enable_xarcade2jstick() {
    cd "$md_inst"
    make installservice
}

function disable_xarcade2jstick() {
    cd "$md_inst"
    make uninstallservice
}

function remove_xarcade2jstick() {
    [[ -f /lib/systemd/system/xarcade2jstick.service ]] && disable_xarcade2jstick
    cd "$md_inst"
    make uninstall
}

function gui_xarcade2jstick() {
    local status
    local options=(
        1 "Enable Xarcade2Jstick Service."
        2 "Disable Xarcade2Jstick Service."
    )
    while true; do
        status="Disabled"
        [[ -f /lib/systemd/system/xarcade2jstick.service ]] && status="Enabled"
        local cmd=(dialog --backtitle "$__backtitle" --menu "Service is currently: $status" 22 86 16)
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && break
        case "$choice" in
            1)
                enable_xarcade2jstick
                printMsgs "dialog" "Enabled Xarcade2Jstick."
                ;;
            2)
                disable_xarcade2jstick
                printMsgs "dialog" "Disabled Xarcade2Jstick service."
                ;;
        esac
    done
}
