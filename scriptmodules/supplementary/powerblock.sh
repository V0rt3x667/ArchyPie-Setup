#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="powerblock"
rp_module_desc="PowerBlock Driver"
rp_module_help="Please Note That You Need To Manually Enable Or Disable The PowerBlock Service In The Configuration Section. IMPORTANT: If The Service Is Enabled And The Power Switch Functionality Is Enabled (Which Is The Default Setting) In The Config File, You Need To Have A Switch Connected To The PowerBlock."
rp_module_repo="git https://github.com/petrockblog/PowerBlock.git master"
rp_module_section="driver"
rp_module_flags="noinstclean !all rpi"

function depends_powerblock() {
    local depends=(
        'cmake'
        'doxygen'
        'raspberrypi-firmware'
    )
    getDepends "${depends[@]}"
}

function sources_powerblock() {
    if [[ -d "${md_inst}" ]]; then
        git -C "${md_inst}" reset --hard
    fi
    gitPullOrClone "${md_inst}"
}

function install_powerblock() {
    cd "${md_inst}" || exit
    bash install.sh
}

function remove_powerblock() {
    cd "${md_inst}" || exit
    bash uninstall.sh
}

function gui_powerblock() {
    local cmd=(dialog --backtitle "${__backtitle}" --menu "Choose An Option" 22 86 16)
    local options=(
        1 "Enable PowerBlock Driver"
        2 "Disable PowerBlock Driver"

    )
    local choice
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "${choice}" ]]; then
        case "${choice}" in
            1)
                install_powerblock
                printMsgs "dialog" "Enabled PowerBlock Driver"
                ;;
            2)
                remove_powerblock
                printMsgs "dialog" "Disabled PowerBlock Driver"
                ;;
        esac
    fi
}
