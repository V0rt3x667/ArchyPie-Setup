#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="joy2key"
rp_module_desc="Provides Joystick To Keyboard Conversion For Navigation Of ArchyPie Dialog Menus"
rp_module_section="core"

function _update_hook_joy2key() {
    # Make sure joy2key is always updated when updating archypie-setup
    rp_isInstalled "${md_id}" && rp_callModule "${md_id}"
}

function depends_joy2key() {
    local depends=('python-urwid')
    getDepends "${depends[@]}"

    local aurdepends=('python-pysdl2-arpie' 'python-uinput-arpie')
    local pkg
    for pkg in "${aurdepends[@]}"; do
        if hasPackage "${pkg}"; then
            return
        else
            pacmanPKGBuild "${pkg}"
        fi
    done
}

function install_bin_joy2key() {
    local file
    for file in "joy2key_sdl.py" "osk.py"; do
        cp "${md_data}/${file}" "${md_inst}/"
        chmod +x "${md_inst}/${file}"
        python -m compileall "${md_inst}/${file}"
    done

    local wrapper="${md_inst}/joy2key"
    cat >"${wrapper}" <<_EOF_
#!/bin/bash
mode="\${1}"
[[ -z "\${mode}" ]] && mode="start"
shift

# Allow Overriding Joystick Device Via __joy2key_dev env (By Default Will Use /dev/input/jsX Which Will Scan All)
device="/dev/input/jsX"
[[ -n "\${__joy2key_dev}" ]] && device="\${__joy2key_dev}"

params=("\${@}")
if [[ "\${#params[@]}" -eq 0 ]]; then
    # Default button-to-keyboard mappings:
    # * cursor keys for axis/dpad
    # * enter, space, esc and tab for buttons 'a', 'b', 'x' and 'y'
    # * page up/page down for buttons 5,6 (shoulder buttons)
    params=(kcub1 kcuf1 kcuu1 kcud1 0x0a 0x20 0x1b 0x09 kpp knp)
fi

script="joy2key_sdl.py"

case "\${mode}" in
    start)
        if pgrep -f "\${script}" &>/dev/null; then
            "\${0}" stop
        fi
        "${md_inst}/\${script}" "\${device}" "\${params[@]}" || exit 1
        ;;
    stop)
        pkill -f "\${script}"
        sleep 0.5
        ;;
esac
exit 0
_EOF_
    chmod +x "${wrapper}"
    if ! grep -q "uinput" /etc/modules; then
        addLineToFile "uinput" "/etc/modules"
    fi

    # Add an udev rule to give 'input' group write access to `/dev/uinput`
    echo 'KERNEL=="uinput", MODE="0660", GROUP="input"' > /etc/udev/rules.d/80-arpi-uinput.rules
    udevadm control --reload

    modprobe uinput

    # Make sure the install user is part of 'input' group
    local group
    group="input"
    if ! hasFlag $(groups "${__user}") "${group}"; then
        usermod -a -G "${group}" "${__user}"
    fi

    joy2keyStart
}

function remove_joy2key() {
    joy2keyStop

    pacmanRemove python-pysdl2-arpie python-uinput-arpie
}
