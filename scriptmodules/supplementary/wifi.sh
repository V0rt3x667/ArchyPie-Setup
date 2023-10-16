#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="wifi"
rp_module_desc="Configure Wi-Fi"
rp_module_section="config"
rp_module_flags="!x11"

function _get_interface_wifi() {
    local iface
    # Look For The First Wireless Interface Present
    for iface in /sys/class/net/*; do
        if [[ -d "${iface}/wireless" ]]; then
            echo "$(basename ${iface})"
            return 0
        fi
    done
    return 1
}

function _get_mgmt_tool_wifi() {
    # Get The Wi-Fi Connection Manager
    if systemctl -q is-active NetworkManager.service; then
        echo "nm"
    else
        echo "wpasupplicant"
    fi
}
function _set_interface_wifi() {
    local iface="${1}"
    local state="${2}"

    if [[ "${state}" == "up" ]]; then
        if ! ifup "${iface}"; then
            ip link set "${iface}" up
        fi
    elif [[ "${state}" == "down" ]]; then
        if ! ifdown "${iface}"; then
            ip link set "${iface}" down
        fi
    fi
}

function remove_nm_wifi() {
    local iface="${1}"
    # Delete The NM Connection Named ArchyPie-WiFi
    nmcli connection delete ArchyPie-WiFi
    _set_interface_wifi ${iface} down 2>/dev/null
}

function remove_wpasupplicant_wifi() {
    local iface="${1}"
    sed -i '/ARCHYPIE CONFIG START/,/ARCHYPIE CONFIG END/d' "/etc/wpa_supplicant/wpa_supplicant.conf"
    _set_interface_wifi ${iface} down 2>/dev/null
}

function list_wifi() {
    local line
    local essid
    local type
    local iface="${1}"

    while read line; do
        [[ "${line}" =~ ^Cell && -n "${essid}" ]] && echo -e "${essid}\n${type}"
        [[ "${line}" =~ ^ESSID ]] && essid=$(echo "${line}" | cut -d\" -f2)
        [[ "${line}" == "Encryption key:off" ]] && type="open"
        [[ "${line}" == "Encryption key:on" ]] && type="wep"
        [[ "${line}" =~ ^IE:.*WPA ]] && type="wpa"
    done < <(iwlist "${iface}" scan | grep -o "Cell .*\|ESSID:\".*\"\|IE: .*WPA\|Encryption key:.*")
    echo -e "${essid}\n${type}"
}

function connect_wifi() {
    local iface
    local mgmt_tool="wpasupplicant"

    iface="$(_get_interface_wifi)"
    if [[ -z "${iface}" ]]; then
        printMsgs "dialog" "No Wireless Interfaces Detected"
        return 1
    fi
    mgmt_tool="$(_get_mgmt_tool_wifi)"

    local essids=()
    local essid
    local types=()
    local type
    local options=()
    i=0
    _set_interface_wifi "${iface}" up 2>/dev/null
    dialog --infobox "\nScanning For Wi-Fi Networks..." 5 40 > /dev/tty
    sleep 1

    while read essid; read type; do
        essids+=("${essid}")
        types+=("${type}")
        options+=("${i}" "${essid}")
        ((i++))
    done < <(list_wifi "${iface}")
    options+=("H" "Hidden ESSID")

    local cmd=(dialog --backtitle "${__backtitle}" --menu "Please Choose The Network You Would Like To Connect To" 22 76 16)
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "${choice}" ]] && return

    local hidden=0
    if [[ "${choice}" == "H" ]]; then
        essid=$(inputBox "ESSID" "" 4)
        [[ -z "${essid}" ]] && return
        cmd=(dialog --backtitle "${__backtitle}" --nocancel --menu "Please Choose The Wi-Fi Type" 12 40 6)
        options=(
            wpa "WPA/WPA2"
            wep "WEP"
            open "Open"
        )
        type=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        hidden=1
    else
        essid=${essids[choice]}
        type=${types[choice]}
    fi

    if [[ "${type}" == "wpa" || "${type}" == "wep" ]]; then
        local key=""
        local key_min
        if [[ "${type}" == "wpa" ]]; then
            key_min=8
        else
            key_min=5
        fi

        cmd=(inputBox "WiFi Key/Password" "" "${key_min}")
        local key_ok=0
        while [[ ${key_ok} -eq 0 ]]; do
            key=$("${cmd[@]}") || return
            key_ok=1
        done
    fi

    create_"${mgmt_tool}"_config_wifi "${type}" "${essid}" "${key}" "${iface}"
    gui_connect_wifi "${iface}"
}

function create_nm_config_wifi() {
    local type="${1}"
    local essid="${2}"
    local key="${3}"
    local dev="${4}"
    local con="ArchyPie-WiFi"

    remove_nm_wifi
    nmcli connection add type wifi ifname "${dev}" ssid "${essid}" con-name "${con}" autoconnect yes
    # Configure Security For The Connection
    case ${type} in
        wpa)
            nmcli connection modify "${con}" \
                wifi-sec.key-mgmt wpa-psk  \
                wifi-sec.psk-flags 0       \
                wifi-sec.psk "${key}"
            ;;
        wep)
            nmcli connection modify "${con}" \
                wifi-sec.key-mgmt none     \
                wifi-sec.wep-key-flags 0   \
                wifi-sec.wep-key-type 2    \
                wifi-sec.wep-key0 "${key}"
            ;;
        open)
            ;;
    esac

    [[ ${hidden} -eq 1 ]] && nmcli connection modify "${con}" wifi.hidden yes
}

function create_wpasupplicant_config_wifi() {
    local type="${1}"
    local essid="${2}"
    local key="${3}"
    local dev="${4}"

    local wpa_config
    wpa_config+="\tssid=\"${essid}\"\n"
    case ${type} in
        wpa)
            wpa_config+="\tpsk=\"${key}\"\n"
            ;;
        wep)
            wpa_config+="\tkey_mgmt=NONE\n"
            wpa_config+="\twep_tx_keyidx=0\n"
            wpa_config+="\twep_key0=${key}\n"
            ;;
        open)
            wpa_config+="\tkey_mgmt=NONE\n"
            ;;
    esac

    [[ "${hidden}" -eq 1 ]] &&  wpa_config+="\tscan_ssid=1\n"

    remove_wpasupplicant_wifi
    wpa_config=$(echo -e "${wpa_config}")
    cat >> "/etc/wpa_supplicant/wpa_supplicant.conf" <<_EOF_
# ARCHYPIE CONFIG START
network={
${wpa_config}
}
# ARCHYPIE CONFIG END
_EOF_
}

function gui_connect_wifi() {
    local iface="${1}"
    local mgmt_tool

    mgmt_tool="$(_get_mgmt_tool_wifi)"
    _set_interface_wifi "${iface}" down 2>/dev/null
    _set_interface_wifi "${iface}" up 2>/dev/null

    if [[ "${mgmt_tool}" == "nm" ]]; then
        nmcli -w 0 connection up ArchyPie-WiFi
    fi

    dialog --backtitle "${__backtitle}" --infobox "\nConnecting ..." 5 40 >/dev/tty
    local id=""
    i=0
    while [[ -z "${id}" && "${i}" -lt 30 ]]; do
        sleep 1
        id=$(iwgetid -r)
        ((i++))
    done
    if [[ -z "${id}" ]]; then
        printMsgs "dialog" "Unable To Connect To Network ${essid}"
        _set_interface_wifi "${iface}" down 2>/dev/null
    fi
}

function gui_wifi() {
    local default
    local iface
    local mgmt_tool

    iface="$(_get_interface_wifi)"
    mgmt_tool="$(_get_mgmt_tool_wifi)"

    while true; do
        local ip_current="$(getIPAddress)"
        local ip_wlan="$(getIPAddress "${iface}")"
        local cmd=(dialog --backtitle "${__backtitle}" --colors --cancel-label "Exit" --item-help --help-button --default-item "${default}" --title "Configure Wi-Fi" --menu "Current IP: \Zb${ip_current:-(unknown)}\ZB\nWireless IP: \Zb${ip_wlan:-(unknown)}\ZB\nWireless ESSID: \Zb$(iwgetid -r || echo "none")\ZB" 22 76 16)
        local options=(
            1 "Connect To Wi-Fi Network"
            "1 Connect to your Wi-Fi network"
            2 "Disconnect/Remove Wi-Fi Config"
            "2 Disconnect and remove any Wi-Fi configuration"
            3 "Import WiFi Credentials From /boot/wifikeyfile.txt"
            "3 Will import the SSID (network name) and PSK (password) from a file at /boot/wifikeyfile.txt

The file should contain two lines as follows\n\nssid = \"YOUR WIFI SSID\"\npsk = \"YOUR PASSWORD\""
        )

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ "${choice[@]:0:4}" == "HELP" ]]; then
            choice="${choice[@]:5}"
            default="${choice/%\ */}"
            choice="${choice#* }"
            printMsgs "dialog" "${choice}"
            continue
        fi
        default="$choice"

        if [[ -n "${choice}" ]]; then
            case "${choice}" in
                1)
                    connect_wifi "${iface}"
                    ;;
                2)
                    dialog --defaultno --yesno "This will remove the Wi-Fi configuration and stop the Wi-Fi.\n\nAre you sure you want to continue?" 12 60 2>&1 >/dev/tty
                    [[ ${?} -ne 0 ]] && continue
                    remove_"${mgmt_tool}"_wifi "${iface}"
                    ;;
                3)
                    if [[ -f "/boot/wifikeyfile.txt" ]]; then
                        iniConfig " = " "\"" "/boot/wifikeyfile.txt"
                        iniGet "ssid"
                        local ssid="${ini_value}"
                        iniGet "psk"
                        local psk="${ini_value}"
                        create_"${mgmt_tool}"_config_wifi "wpa" "${ssid}" "${psk}" "${iface}"
                        gui_connect_wifi "${iface}"
                    else
                        printMsgs "dialog" "No /boot/wifikeyfile.txt Found"
                    fi
                    ;;
            esac
        else
            break
        fi
    done
}
