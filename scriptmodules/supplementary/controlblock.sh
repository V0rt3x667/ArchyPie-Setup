#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="controlblock"
rp_module_desc="ControlBlock Driver"
rp_module_help="Please Note That You Need To Manually Enable Or Disable The ControlBlock Service In The Configuration Section. IMPORTANT: If The Service Is Enabled And The Power Switch Functionality Is Enabled (Which Is The Default Setting) In The Config File, You Need To Have A Switch Connected To The ControlBlock."
rp_module_licence="NONCOM https://raw.githubusercontent.com/petrockblog/ControlBlockService2/master/LICENSE.txt"
rp_module_repo="git https://github.com/petrockblog/ControlBlockService2.git master"
rp_module_section="driver"
rp_module_flags="noinstclean !all rpi"

function depends_controlblock() {
    local depends=(
        'cmake'
        'doxygen'
        'libgpiod'
        'raspberrypi-firmware'
    )
    getDepends "${depends[@]}"
}

function sources_controlblock() {
    if [[ -d "${md_inst}" ]]; then
        git -C "${md_inst}" reset --hard
    fi
    gitPullOrClone "${md_inst}"
}

function install_controlblock() {
    cd "${md_inst}" || exit
    bash install.sh
}

function remove_controlblock() {
    cd "${md_inst}" || exit
    bash uninstall.sh
}

function gui_controlblock() {
    local cmd=(dialog --backtitle "$__backtitle" --menu "Choose An Option" 22 86 16)
    local options=(
        1 "Enable ControlBlock Driver"
        2 "Disable ControlBlock Driver"

    )
    local choice
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "${choice}" ]]; then
        case "${choice}" in
            1)
                install_controlblock
                printMsgs "dialog" "Enabled ControlBlock Driver"
                ;;
            2)
                remove_controlblock
                printMsgs "dialog" "Disabled ControlBlock Driver"
                ;;
        esac
    fi
}
