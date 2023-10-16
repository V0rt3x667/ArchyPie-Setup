#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="joy2key"
rp_module_desc="Provides Joystick To Keyboard Conversion For Navigation Of ArchyPie Dialog Menus"
rp_module_section="core"

function _update_hook_joy2key() {
    # Make Sure joy2key Is Always Updated
    rp_isInstalled "${md_id}" && rp_callModule "${md_id}"
}

function depends_joy2key() {
    # Remove Previously Installed PySDL2
    pip list | grep "PySDL2" &>/dev/null
    if [[ "${?}" -eq 0 ]]; then
        pip uninstall "PySDL2" --break-system-packages -y
    fi

    # Build & Install PySDL2 From The AUR
    local builddir="${__builddir}/pkg"
    mkdir "${builddir}"
    chmod a+w "${builddir}"
    gitPullOrClone "${builddir}" "https://aur.archlinux.org/python-pysdl2"
    su "${user}" -c 'cd '"${builddir}"' && makepkg -cfs --noconfirm'
    pacman -U "${builddir}"/python-pysdl2*.pkg.tar.zst --needed --noconfirm
    rm -rf "${builddir}"
}

function install_bin_joy2key() {
    local file
    for file in "joy2key.py" "joy2key_sdl.py" "osk.py"; do
        cp "${md_data}/${file}" "${md_inst}/"
        chmod +x "${md_inst}/${file}"
        python -m compileall "${md_inst}/${file}"
    done

    local wrapper="${md_inst}/joy2key"
    cat >"${wrapper}" <<_EOF_
#!/usr/bin/env bash
mode="\${1}"
[[ -z "\${mode}" ]] && mode="start"
shift

# Allow Overriding Joystick Device Via __joy2key_dev env (By Default Will Use /dev/input/jsX Which Will Scan All)
device="/dev/input/jsX"
[[ -n "\${__joy2key_dev}" ]] && device="\${__joy2key_dev}"

params=("\${@}")
if [[ "\${#params[@]}" -eq 0 ]]; then
    # Default Button-to-keyboard Mappings:
    # * Cursor Keys for Axis/Dpad
    # * enter, space, esc & tab For Buttons 'a', 'b', 'x' and 'y'
    # * page up/page down For Buttons 5,6 (Shoulder Buttons)
    params=(kcub1 kcuf1 kcuu1 kcud1 0x0a 0x20 0x1b 0x09 kpp knp)
fi

script="joy2key_sdl.py"
! python -c "import sdl2" 2>/dev/null && script="joy2key.py"

case "\${mode}" in
    start)
        if pgrep -f "\${script}" &>/dev/null; then
            "\${0}" stop
        fi
        "${md_inst}/\${script}" "\${device}" "\${params[@]}" || exit 1
        ;;
    stop)
        pkill -f "\${script}"
        sleep 1
        ;;
esac
exit 0
_EOF_
    chmod +x "${wrapper}"

    joy2keyStart
}

function remove_joy2key() {
    joy2keyStop
}
