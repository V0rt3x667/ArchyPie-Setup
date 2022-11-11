#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="wifi"
rp_module_desc="Configure WiFi"
rp_module_section="config"
rp_module_flags=""

function depends_wifi() {
    local depends=(
        'wireless_tools'
        'wireless-regdb'
        'wpa_supplicant'
    )
    getDepends "${depends[@]}"
}

function _set_interface_wifi() {
    local state="$1"

    if [[ "$state" == "up" ]]; then
        if ! ifup wlan0; then
            ip link set wlan0 up
        fi
    elif [[ "$state" == "down" ]]; then
        if ! ifdown wlan0; then
            ip link set wlan0 down
        fi
    fi
}

function remove_wifi() {
    sed -i '/ARCHYPIE CONFIG START/,/ARCHYPIE CONFIG END/d' "/etc/wpa_supplicant/wpa_supplicant.conf"
    _set_interface_wifi down 2>/dev/null
}

function list_wifi() {
    local line
    local essid
    local type
    while read line; do
        [[ "$line" =~ ^Cell && -n "$essid" ]] && echo -e "$essid\n$type"
        [[ "$line" =~ ^ESSID ]] && essid=$(echo "$line" | cut -d\" -f2)
        [[ "$line" == "Encryption key:off" ]] && type="open"
        [[ "$line" == "Encryption key:on" ]] && type="wep"
        [[ "$line" =~ ^IE:.*WPA ]] && type="wpa"
    done < <(iwlist wlan0 scan | grep -o "Cell .*\|ESSID:\".*\"\|IE: .*WPA\|Encryption key:.*")
    echo -e "$essid\n$type"
}

function connect_wifi() {
    if [[ ! -d "/sys/class/net/wlan0/" ]]; then
        printMsgs "dialog" "No wlan0 interface detected"
        return 1
    fi
    local essids=()
    local essid
    local types=()
    local type
    local options=()
    i=0
    _set_interface_wifi up 2>/dev/null
    dialog --infobox "\nScanning for WiFi networks..." 5 40 > /dev/tty
    sleep 1

    while read essid; read type; do
        essids+=("$essid")
        types+=("$type")
        options+=("$i" "$essid")
        ((i++))
    done < <(list_wifi)
    options+=("H" "Hidden ESSID")

    local cmd=(dialog --backtitle "$__backtitle" --menu "Please choose the network you would like to connect to" 22 76 16)
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "$choice" ]] && return

    local osk
    osk="$(rp_getInstallPath joy2key)/osk.py"

    local hidden=0
    if [[ "$choice" == "H" ]]; then
        cmd=(python "$osk" --backtitle "$__backtitle" --inputbox "ESSID" --minchars 4)
        essid=$("${cmd[@]}" 2>&1 >/dev/tty)
        [[ -z "$essid" ]] && return
        cmd=(dialog --backtitle "$__backtitle" --nocancel --menu "Please choose the WiFi type" 12 40 6)
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

    if [[ "$type" == "wpa" || "$type" == "wep" ]]; then
        local key=""
        local key_min
        if [[ "$type" == "wpa" ]]; then
            key_min=8
        else
            key_min=5
        fi

        cmd=(python $osk --backtitle "$__backtitle" --inputbox "WiFi key/password" --minchars $key_min)
        local key_ok=0
        while [[ $key_ok -eq 0 ]]; do
            key=$("${cmd[@]}" 2>&1 >/dev/tty) || return
            key_ok=1
        done
    fi

    create_config_wifi "$type" "$essid" "$key"

    gui_connect_wifi
}

function create_config_wifi() {
    local type="$1"
    local essid="$2"
    local key="$3"

    local wpa_config
    wpa_config+="\tssid=\"$essid\"\n"
    case $type in
        wpa)
            wpa_config+="\tpsk=\"$key\"\n"
            ;;
        wep)
            wpa_config+="\tkey_mgmt=NONE\n"
            wpa_config+="\twep_tx_keyidx=0\n"
            wpa_config+="\twep_key0=$key\n"
            ;;
        open)
            wpa_config+="\tkey_mgmt=NONE\n"
            ;;
    esac

    [[ $hidden -eq 1 ]] &&  wpa_config+="\tscan_ssid=1\n"

    remove_wifi
    wpa_config=$(echo -e "$wpa_config")
    cat >> "/etc/wpa_supplicant/wpa_supplicant.conf" <<_EOF_
# ARCHYPIE CONFIG START
network={
$wpa_config
}
# ARCHYPIE CONFIG END
_EOF_
}

function gui_connect_wifi() {
    _set_interface_wifi down 2>/dev/null
    _set_interface_wifi up 2>/dev/null
    dialog --backtitle "$__backtitle" --infobox "\nConnecting ..." 5 40 >/dev/tty
    local id=""
    i=0
    while [[ -z "$id" && $i -lt 30 ]]; do
        sleep 1
        id=$(iwgetid -r)
        ((i++))
    done
    if [[ -z "$id" ]]; then
        printMsgs "dialog" "Unable to connect to network $essid"
        _set_interface_wifi down 2>/dev/null
    fi
}

function gui_wifi() {
    local default
    while true; do
        local ip_current="$(getIPAddress)"
        local ip_wlan="$(getIPAddress wlan0)"
        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Exit" --item-help --help-button --default-item "$default" --menu "Configure WiFi\nCurrent IP: ${ip_current:-(unknown)}\nWireless IP: ${ip_wlan:-(unknown)}\nWireless ESSID: $(iwgetid -r)" 22 76 16)
        local options=(
            1 "Connect to WiFi network"
            "1 Connect to your WiFi network"
            2 "Disconnect/Remove WiFi config"
            "2 Disconnect and remove any WiFi configuration"
            3 "Import WiFi credentials from /boot/wifikeyfile.txt"
            "3 Will import the SSID (network name) and PSK (password) from a file at /boot/wifikeyfile.txt

The file should contain two lines as follows\n\nssid = \"YOUR WIFI SSID\"\npsk = \"YOUR PASSWORD\""
        )

        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ "${choice[@]:0:4}" == "HELP" ]]; then
            choice="${choice[@]:5}"
            default="${choice/%\ */}"
            choice="${choice#* }"
            printMsgs "dialog" "$choice"
            continue
        fi
        default="$choice"

        if [[ -n "$choice" ]]; then
            case "$choice" in
                1)
                    connect_wifi
                    ;;
                2)
                    dialog --defaultno --yesno "This will remove the WiFi configuration and stop the WiFi.\n\nAre you sure you want to continue ?" 12 35 2>&1 >/dev/tty
                    [[ $? -ne 0 ]] && continue
                    remove_wifi
                    ;;
                3)
                    if [[ -f "/boot/wifikeyfile.txt" ]]; then
                        iniConfig " = " "\"" "/boot/wifikeyfile.txt"
                        iniGet "ssid"
                        local ssid="$ini_value"
                        iniGet "psk"
                        local psk="$ini_value"
                        create_config_wifi "wpa" "$ssid" "$psk"
                        gui_connect_wifi
                    else
                        printMsgs "dialog" "No /boot/wifikeyfile.txt found"
                    fi
                    ;;
            esac
        else
            break
        fi
    done
}
