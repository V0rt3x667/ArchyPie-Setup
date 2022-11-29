#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="joy2key"
rp_module_desc="Provides Joystick to Keyboard Conversion for Navigation of ArchyPie Dialog Menus"
rp_module_section="core"

function _update_hook_joy2key() {
    # Make sure joy2key is always updated when updating archypie-setup
    rp_isInstalled "$md_id" && rp_callModule "$md_id"
}

function depends_joy2key() {
    local depends=(
        'python-pip'
        'python-pyudev'
        'python-six'
        'python-urwid'
        'python-wheel'
    )
    getDepends "${depends[@]}"

    pip install -U git+https://github.com/marcusva/py-sdl2.git
}

function install_bin_joy2key() {
    local file
    for file in "joy2key.py" "joy2key_sdl.py" "osk.py"; do
        cp "$md_data/$file" "$md_inst/"
        chmod +x "$md_inst/$file"
        python -m compileall "$md_inst/$file"
    done

    local wrapper="$md_inst/joy2key"
    cat >"$wrapper" <<_EOF_
#!/bin/bash
mode="\$1"
[[ -z "\$mode" ]] && mode="start"
shift

# Allow overriding joystick device via __joy2key_dev env (by default will use /dev/input/jsX which will scan all)
device="/dev/input/jsX"
[[ -n "\$__joy2key_dev" ]] && device="\$__joy2key_dev"

params=("\$@")
if [[ "\${#params[@]}" -eq 0 ]]; then
    # Default button-to-keyboard mappings:
    # * cursor keys for axis/dpad
    # * enter, space, esc and tab for buttons 'a', 'b', 'x' and 'y'
    # * page up/page down for buttons 5,6 (shoulder buttons)
    params=(kcub1 kcuf1 kcuu1 kcud1 0x0a 0x20 0x1b 0x09 kpp knp)
fi

script="joy2key_sdl.py"
! python -c "import sdl2" 2>/dev/null && script="joy2key.py"

case "\$mode" in
    start)
        if pgrep -f "\$script" &>/dev/null; then
            "\$0" stop
        fi
        "$md_inst/\$script" "\$device" "\${params[@]}" || exit 1
        ;;
    stop)
        pkill -f "\$script"
        sleep 1
        ;;
esac
exit 0
_EOF_
    chmod +x "$wrapper"

    joy2keyStart
}

function remove_joy2key() {
    joy2keyStop
}
