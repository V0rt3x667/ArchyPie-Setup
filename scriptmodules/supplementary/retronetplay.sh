#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="retronetplay"
rp_module_desc="RetroArch Netplay: Play Games Online"
rp_module_section="config"

function rps_retronet_saveconfig() {
    local conf="${configdir}/all/retronetplay.cfg"
    cat >"${conf}"  <<_EOF_
__netplaymode="${__netplaymode}"
__netplayport="${__netplayport}"
__netplayhostip="${__netplayhostip}"
__netplayhostip_cfile="${__netplayhostip_cfile}"
__netplaynickname="'${__netplaynickname}'"
_EOF_
    chown "${__user}":"${__group}" "${conf}"
    printMsgs "dialog" "Configuration Has Been Saved To: ${conf}"
}

function rps_retronet_loadconfig() {
    if [[ -f "${configdir}/all/retronetplay.cfg" ]]; then
        source "${configdir}/all/retronetplay.cfg"
    else
        __netplayenable="D"
        __netplaymode="H"
        __netplayport="55435"
        __netplayhostip="192.168.0.1"
        __netplayhostip_cfile=""
        __netplaynickname="ArchyPie"
    fi
}

function rps_retronet_mode() {
    cmd=(dialog --backtitle "${__backtitle}" --menu "Please Set The Netplay Mode" 22 76 16)
    options=(1 "Set as HOST"
             2 "Set as CLIENT" )
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "${choice}" ]]; then
        case "${choice}" in
             1) __netplaymode="H"
                __netplayhostip_cfile=""
                ;;
             2) __netplaymode="C"
                __netplayhostip_cfile="${__netplayhostip}"
                ;;
        esac
    fi
}

function rps_retronet_port() {
    cmd=(dialog --backtitle "${__backtitle}" --inputbox "Please Enter The Port To Be Used For Netplay (Default: 55435)" 22 76 "${__netplayport}")
    choice=$("${cmd[@]}" 2>&1 >/dev/tty)
    if [[ -n "${choice}" ]]; then
        __netplayport="${choice}"
    fi
}

function rps_retronet_hostip() {
    cmd=(dialog --backtitle "${__backtitle}" --inputbox "Please Enter The IP Address Of The Host." 22 76 "${__netplayhostip}")
    choice=$("${cmd[@]}" 2>&1 >/dev/tty)
    if [[ -n "${choice}" ]]; then
        __netplayhostip="${choice}"
        if [[ ${__netplaymode} == "H" ]]; then
            __netplayhostip_cfile=""
        else
            __netplayhostip_cfile="${__netplayhostip}"
        fi
    fi
}

function rps_retronet_nickname() {
    cmd=(dialog --backtitle "${__backtitle}" --inputbox "Please Enter The Nickname You Wish To Use (Default: ArchyPie)" 22 76 "${__netplaynickname}")
    choice=$("${cmd[@]}" 2>&1 >/dev/tty)
    if [[ -n "${choice}" ]]; then
        __netplaynickname="${choice}"
    fi
}

function gui_retronetplay() {
    rps_retronet_loadconfig

    local ip_ext
    local ip_int

    ip_int=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
    ip_ext=$(curl -4 http://ipecho.net/plain)

    while true; do
        cmd=(dialog --backtitle "${__backtitle}" --menu "Configure RetroArch Netplay\nInternal IP: ${ip_int} External IP: ${ip_ext}" 22 76 16)
        options=(
            1 "Set Mode, (H)ost Or (C)lient. Currently: ${__netplaymode}"
            2 "Set Port. Currently: ${__netplayport}"
            3 "Set Host IP Address (For Client Mode). Currently: ${__netplayhostip}"
            4 "Set Netplay Nickname. Currently: ${__netplaynickname}"
            5 "Save Configuration"
        )
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "${choice}" ]]; then
            case "${choice}" in
                1)
                    rps_retronet_mode
                    ;;
                2)
                    rps_retronet_port
                    ;;
                3)
                    rps_retronet_hostip
                    ;;
                4)
                    rps_retronet_nickname
                    ;;
                5)
                    rps_retronet_saveconfig
                    ;;
            esac
        else
            break
        fi
    done
}
