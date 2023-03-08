#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="consolefont"
rp_module_desc="Configure Default Console Font Size & Type"
rp_module_section="config"
rp_module_flags="!x11 !wayland"

function set_consolefont() {
    iniConfig "=" '"' "/etc/default/console-setup"
    iniSet "FONTFACE" "$1"
    iniSet "FONTSIZE" "$2"
    service console-setup restart
    # Force Font Configuration Update If Running From A Pseudo-Terminal
    [[ "$(tty | grep -E '/dev/tty[1-6]')" == "" ]] && setupcon -f --force
}

function check_consolefont() {
    local fontface
    local fontsize

    iniConfig "=" '"' "/etc/default/console-setup"
    iniGet "FONTFACE"
    fontface="${ini_value}"
    iniGet "FONTSIZE"
    fontsize="${ini_value}"
    echo "${fontface}" "${fontsize}"
}

function gui_consolefont() {
    local choice
    local cmd
    local options

    cmd=(dialog --backtitle "${__backtitle}" --menu "Choose The Desired Console Font Configuration:\n(Current Configuration: $(check_consolefont))" 22 86 16)
    options=(
        1 "Large (VGA 16x32)"
        2 "Large (TerminusBold 16x32)"
        3 "Medium (VGA 16x28)"
        4 "Medium (TerminusBold 14x28)"
        5 "Small (Fixed 8x16)"
        6 "Smaller (VGA 8x8)"
        D "Default (Kernel Font 8x16 - Restart Needed)"
    )
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "${choice}" ]]; then
        case "${choice}" in
            1)
                set_consolefont "VGA" "16x32"
                ;;
            2)
                set_consolefont "TerminusBold" "16x32"
                ;;
            3)
                set_consolefont "VGA" "16x28"
                ;;
            4)
                set_consolefont "TerminusBold" "14x28"
                ;;
            5)
                set_consolefont "Fixed" "8x16"
                ;;
            6)
                set_consolefont "VGA" "8x8"
                ;;
            D)
                set_consolefont "" ""
                ;;
        esac
        if [[ "${choice}" == "D" ]]; then
            printMsgs "dialog" "Default Kernel Font Will Be Used.\n\nYou Will Need To Reboot To See The Change."
        else
            printMsgs "dialog" "New Font Configuration Applied: $(check_consolefont)"
        fi
    fi
}
