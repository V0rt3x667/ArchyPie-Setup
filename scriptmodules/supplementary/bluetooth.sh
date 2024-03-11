#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="bluetooth"
rp_module_desc="Configure Bluetooth Devices"
rp_module_section="config"

function _update_hook_bluetooth() {
    local mode
    mode="$(_get_connect_mode)"

    # Install The latest Dependencies & Update 'systemd' Script
    if [[ "${mode}" != "default" ]]; then
        ! hasPackage "bluez-tools" && depends_bluetooth
        connect_mode_set_bluetooth "${mode}"
    fi
}

function depends_bluetooth() {
    local depends=(
        'bluez-deprecated-tools'
        'bluez-plugins'
        'bluez-tools'
        'bluez-utils'
        'bluez'
        'dbus-python'
        'python-docutils'
        'python-gobject'
    )
    getDepends "${depends[@]}"
}

function _get_connect_mode() {
    # Get Bluetooth Config
    iniConfig "=" '"' "${configdir}/all/bluetooth.cfg"
    iniGet "connect_mode"
    if [[ -n "${ini_value}" ]]; then
        echo "${ini_value}"
    else
        echo "default"
    fi
}

function get_script_bluetooth() {
    name="${1}"
    if ! which "${name}"; then
        [[ "${name}" == "bluez-test-input" ]] && name="bluez-test-device"
        name="${md_data}/${name}"
    fi
    echo "${name}"
}

function _slowecho_bluetooth() {
    local line

    IFS=$'\n'
    for line in $(echo -e "${1}"); do
        echo -e "${line}"
        sleep 1
    done
    unset IFS
}

function bluez_cmd_bluetooth() {
    # Create A Named Pipe & fd For Input For 'bluetoothctl'
    local fifo
    fifo="$(mktemp -u)"
    mkfifo "${fifo}"
    exec 3<>"${fifo}"
    local line
    while true; do
        _slowecho_bluetooth "${1}" >&3
        # Collect Output For Specified Amount Of Time, Then Echo It
        while read -r line; do
            printf '%s\n' "${line}"
            # (Slow) Reply To Any Optional Challenges
            if [[ -n "${3}" && "${line}" =~ ${3} ]]; then
                _slowecho_bluetooth "${4}" >&3
            fi
        done
        _slowecho_bluetooth "quit\n" >&3
        break
    # Read From 'bluetoothctl' Buffered Line By Line
    done < <(timeout "${2}" stdbuf -oL bluetoothctl --agent=NoInputNoOutput <&3)
    exec 3>&-
}

function list_available_bluetooth() {
    local mac
    local name
    local info_text="\n\nSearching ..."

    declare -A paired=()
    declare -A found=()

    # Get An 'asc' Array Of Paired MAC Addresses
    while read -r mac; read -r name; do
        paired+=(["${mac}"]="${name}")
    done < <(list_paired_bluetooth)

    # Dualshock Controller: Add USB Pairing Information
    [[ -n "$(lsmod | grep hid_sony)" ]] && info_text="Searching ...\n\nDualShock Registration: While this text is visible, unplug the controller, press the PS/SHARE button, and then replug the controller."

    dialog --backtitle "${__backtitle}" --infobox "${info_text}" 7 60 >/dev/tty
    if hasPackage bluez; then
        # Dualshock Controller: Reply To Authorization Challenge On USB Cable Connect
        while read -r mac; read -r name; do
            found+=(["${mac}"]="${name}")
       done < <(bluez_cmd_bluetooth "default-agent\nscan on" "15" "Authorize service$" "yes" >/dev/null; bluez_cmd_bluetooth "devices" "3" | grep "^Device " | cut -d" " -f2,3- | sed 's/ /\n/')
    else
        while read -r; read -r mac; read -r name; do
            found+=(["${mac}"]="${name}")
        done < <(hcitool scan --flush | tail -n +2 | sed 's/\t/\n/g')
    fi

    # Display Any Found Addresses That Are Not Already Paired
    for mac in "${!found[@]}"; do
        if [[ -z "${paired[${mac}]}" ]]; then
            echo "${mac}"
            echo "${found[${mac}]}"
        fi
    done
}

function list_registered_bluetooth() {
    local line
    while read -r line; do
        if [[ "${line}" =~ ^(.+)\ \((.+)\)$ ]]; then
            echo "${BASH_REMATCH[2]}"
            echo "${BASH_REMATCH[1]}"
        fi
    done < <(bt-device --list 2>/dev/null)
}

function _devices_grep_bluetooth() {
    declare -A devices=()
    local pattern="${1}"

    local mac
    local name
    while read -r mac; read -r name; do
        if bt-device --info "${mac}" 2>/dev/null | grep -q "${pattern}"; then
            echo "${mac}"
            echo "${name}"
        fi
    done < <(list_registered_bluetooth)
}

function list_paired_bluetooth() {
    _devices_grep_bluetooth "Paired: 1"
}

function list_connected_bluetooth() {
    _devices_grep_bluetooth "Connected: 1"
}

function status_bluetooth() {
    local paired
    local connected

    local mac
    local name

    while read -r mac; read -r name; do
        paired+="${mac} - ${name}\n"
    done < <(list_paired_bluetooth)
    [[ -z "${paired}" ]] && paired="There Are No Paired Devices"

    while read -r mac; read -r name; do
        connected+="${mac} - ${name}\n"
    done < <(list_connected_bluetooth)
    [[ -z "${connected}" ]] && connected="There Are No Connected Devices"

    echo -e "Paired Devices:\n\n${paired}\nConnected Devices:\n\n${connected}"
}

function remove_device_bluetooth() {
    declare -A devices=()
    local mac
    local name

    local options=()

    # Show Paired Devices First
    while read -r mac; read -r name; do
        devices+=(["${mac}"]="${name}")
        options+=("${mac}" "${name}")
    done < <(list_paired_bluetooth)

    # Then List All Other Devices Known
    while read -r mac; read -r name; do
        if [[ -z "${devices[${mac}]}" ]]; then
            devices+=(["${mac}"]="${name}")
            options+=("${mac}" "${name}")
        fi
    done < <(list_registered_bluetooth)

    if [[ ${#devices[@]} -eq 0 ]] ; then
        printMsgs "dialog" "There Are No Devices To Remove"
    else
        local cmd=(dialog --backtitle "${__backtitle}" --menu "Please Choose The Bluetooth Device You Would Like To Remove" 22 76 16)
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "${choice}" ]] && return

        local out
        out=$(bt-device --remove "${choice}" 2>&1)
        if [[ "${?}" -eq 0 ]] ; then
            printMsgs "dialog" "Device Removed"
        else
            printMsgs "dialog" "Error Removing Device:\n\n${out}"
        fi
    fi
}

function pair_bluetooth() {
    declare -A devices=()
    local mac
    local name
    local options=()

    while read -r mac; read -r name; do
        devices+=(["${mac}"]="${name}")
        options+=("${mac}" "${name}")
    done < <(list_available_bluetooth)

    if [[ ${#devices[@]} -eq 0 ]] ; then
        printMsgs "dialog" "No Devices Were Found. Ensure The Device Is On & Try Again"
        return
    fi

    local cmd=(dialog --backtitle "${__backtitle}" --menu "Please Choose The Bluetooth Device You Would Like To Connect To" 22 76 16)
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "${choice}" ]] && return

    mac="${choice}"
    name="${devices[${choice}]}"

    if [[ "${name}" =~ "PLAYSTATION(R)3 Controller" ]]; then
        bt-device --disconnect="${mac}" >/dev/null
        bt-device --set "${mac}" Trusted 1 >/dev/null
        if [[ "${?}" -eq 0 ]]; then
            printMsgs "dialog" "Successfully Authenticated ${name} (${mac}).\n\nYou Can Now Remove The USB Cable."
        else
            printMsgs "dialog" "Unable To Authenticate ${name} (${mac}).\n\nPlease Try To Pair The Device Again, Making Sure To Follow The On-Screen Steps Exactly."
        fi
        return
    fi

    local cmd=(dialog --backtitle "${__backtitle}" --menu "Please Choose The Security Mode - Try The First One, Then Second If That Fails" 22 76 16)
    options=(
        1 "DisplayYesNo"
        2 "KeyboardDisplay"
        3 "NoInputNoOutput"
        4 "DisplayOnly"
        5 "KeyboardOnly"
    )
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -z "${choice}" ]] && return

    local mode="${options[choice*2-1]}"

    # Create A Named Pipe & fd For Input For 'bluez-simple-agent'
    local fifo
    fifo="$(mktemp -u)"
    mkfifo "${fifo}"
    exec 3<>"${fifo}"
    local line
    local pin
    local error=""
    local skip_connect=0
    while read -r line; do
        case "${line}" in
            "RequestPinCode"*)
                cmd=(dialog --nocancel --backtitle "${__backtitle}" --menu "Please Choose A PIN" 22 76 16)
                options=(
                    1 "PIN 0000"
                    2 "Enter Own PIN"
                )
                choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
                pin="0000"
                if [[ "${choice}" == "2" ]]; then
                    pin=$(dialog --backtitle "${__backtitle}" --inputbox "Please Enter A PIN" 10 60 2>&1 >/dev/tty)
                fi
                dialog --backtitle "${__backtitle}" --infobox "Please Enter PIN ${pin} On Your Bluetooth Device" 10 60
                echo "${pin}" >&3
                # Read "Enter PIN Code:"
                read -r -n 15 line
                ;;
            "RequestConfirmation"*)
                # Read "Confirm Passkey (Yes/No):"
                echo "yes" >&3
                read -r -n 26 line
                skip_connect=1
                break
                ;;
            "DisplayPasskey"*|"DisplayPinCode"*)
                # Extract Key From End Of Line
                # DisplayPasskey (/org/bluez/1284/hci0/dev_01_02_03_04_05_06, 123456)
                [[ "${line}" =~ ,\ (.+)\) ]] && pin=${BASH_REMATCH[1]}
                dialog --backtitle "${__backtitle}" --infobox "Please Enter PIN ${pin} On Your Bluetooth Device" 10 60
                ;;
            "Creating device failed"*)
                error="${line}"
                ;;
        esac
    # Read From Bluez-Simple-Agent Buffered Line By Line
    done < <(stdbuf -oL "$(get_script_bluetooth bluez-simple-agent)" -c "${mode}" hci0 "${mac}" <&3)
    exec 3>&-
    rm -f "${fifo}"

    if [[ "${skip_connect}" -eq 1 ]]; then
        if hcitool con | grep -q "${mac}"; then
            printMsgs "dialog" "Successfully Paired & Connected To ${mac}"
            return 0
        else
            printMsgs "dialog" "Unable To Connect To Bluetooth Device. Please Try Pairing With The Commandline Tool 'bluetoothctl'"
            return 1
        fi
    fi

    if [[ -z "${error}" ]]; then
        error=$(bt-device --set "${mac}" Trusted 1 2>&1)
        if [[ "${?}" -eq 0 ]] ; then
            return 0
        fi
    fi

    printMsgs "dialog" "An Error Occurred Connecting To The Bluetooth Device (${error})"
    return 1
}

function udev_bluetooth() {
    declare -A devices=()
    local mac
    local name
    local options=()
    while read -r mac; read -r name; do
        devices+=(["${mac}"]="${name}")
        options+=("${mac}" "${name}")
    done < <(list_paired_bluetooth)

    if [[ ${#devices[@]} -eq 0 ]] ; then
        printMsgs "dialog" "There Are No Paired Bluetooth Devices"
    else
        local cmd=(dialog --backtitle "${__backtitle}" --menu "Please Choose The Bluetooth Device You Would Like To Create A udev Rule For" 22 76 16)
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "${choice}" ]] && return
        name="${devices[${choice}]}"
        local config="/etc/udev/rules.d/99-bluetooth.rules"
        if ! grep -q "${name}" "${config}"; then
            local line="SUBSYSTEM==\"input\", ATTRS{name}==\"${name}\", MODE=\"0666\", ENV{ID_INPUT_JOYSTICK}=\"1\""
            addLineToFile "${line}" "${config}"
            printMsgs "dialog" "Added ${line} To ${config}\n\nPlease Reboot For The Configuration To Take Effect"
        else
            printMsgs "dialog" "An Entry Already Exists For ${name} In ${config}"
        fi
    fi
}

function connect_bluetooth() {
    local mac
    local name
    while read -r mac; read -r name; do
        bt-device --connect "${mac}" 2>/dev/null
    done < <(list_paired_bluetooth)
}

function connect_mode_gui_bluetooth() {
    local mode
    mode="$(_get_connect_mode)"
    [[ -z "${mode}" ]] && mode="default"

    local cmd=(dialog --backtitle "${__backtitle}" --default-item "${mode}" --menu "Choose A Connect Mode" 22 76 16)

    local options=(
        default "Bluetooth Stack Default Behaviour (Recommended)"
        boot "Connect To Devices Once At Boot"
        background "Force Connecting To Devices In The Background"
    )

    local choice
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    [[ -n "${choice}" ]] && connect_mode_set_bluetooth "${choice}"
}

function connect_mode_set_bluetooth() {
    local mode="${1}"
    [[ -z "${mode}" ]] && mode="default"

    local config="/etc/systemd/system/connect-bluetooth.service"
    case "${mode}" in
        boot|background)
            mkdir -p "${md_inst}"
            sed -e "s#CONFIGDIR#${configdir}#" -e "s#ROOTDIR#${rootdir#}" "${md_data}/connect.sh" >"${md_inst}/connect.sh"
            chmod a+x "${md_inst}/connect.sh"
            cat > "${config}" << _EOF_
[Unit]
Description=Connect Bluetooth

[Service]
Type=simple
ExecStart=nice -n19 "${md_inst}/connect.sh"

[Install]
WantedBy=multi-user.target
_EOF_
            systemctl enable "${config}"
            ;;
        default)
            if systemctl is-enabled connect-bluetooth 2>/dev/null | grep -q "enabled"; then
               systemctl disable "${config}"
            fi
            rm -f "${config}"
            rm -rf "${md_inst}"
            ;;
    esac
    iniConfig "=" '"' "${configdir}/all/bluetooth.cfg"
    iniSet "connect_mode" "${mode}"
    chown "${user}:${user}" "${configdir}/all/bluetooth.cfg"
}

function gui_bluetooth() {
    addAutoConf "8bitdo_hack" 0

    while true; do
        local connect_mode
        connect_mode="$(_get_connect_mode)"

        local cmd=(dialog --backtitle "${__backtitle}" --menu "Configure Bluetooth Devices" 22 76 16)
        local options=(
            P "Pair & Connect To Bluetooth Device"
            X "Remove Bluetooth Device"
            S "Show Paired & Connected Bluetooth Devices"
            U "Setup udev Rule For Joypad (Required For Joypads From 8Bitdo)"
            C "Connect Now To All Paired Devices"
            M "Configure Bluetooth Connect Mode (Currently: ${connect_mode})"
        )

        local atebitdo
        if getAutoConf 8bitdo_hack; then
            atebitdo=1
            options+=(8 "8Bitdo Mapping Hack (ON - Old Firmware)")
        else
            atebitdo=0
            options+=(8 "8Bitdo Mapping Hack (OFF - New Firmware)")
        fi

        local choice
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "${choice}" ]]; then
            case "${choice}" in
                P)
                    pair_bluetooth
                    ;;
                X)
                    remove_device_bluetooth
                    ;;
                S)
                    printMsgs "dialog" "$(status_bluetooth)"
                    ;;
                U)
                    udev_bluetooth
                    ;;
                C)
                    connect_bluetooth
                    ;;
                M)
                    connect_mode_gui_bluetooth
                    ;;
                8)
                    atebitdo="$((atebitdo ^ 1))"
                    setAutoConf "8bitdo_hack" "${atebitdo}"
                    ;;
            esac
        fi
    done
}
