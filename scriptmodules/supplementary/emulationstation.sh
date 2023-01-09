#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="emulationstation"
rp_module_desc="EmulationStation: Frontend for Launching Emulators"
rp_module_licence="MIT https://raw.githubusercontent.com/RetroPie/EmulationStation/master/LICENSE.md"
rp_module_repo="git https://github.com/RetroPie/EmulationStation.git stable"
rp_module_section="core"
rp_module_flags="frontend"

function _get_input_cfg_emulationstation() {
    echo "${configdir}/all/emulationstation/es_input.cfg"
}

function _update_hook_emulationstation() {
    # Make Sure The Input Configuration & Launch Scripts Are Updated
    if rp_isInstalled "${md_id}"; then
        copy_inputscripts_emulationstation
        install_launch_emulationstation
    fi
}

function _sort_systems_emulationstation() {
    local field="$1"
    cp "/etc/emulationstation/es_systems.cfg" "/etc/emulationstation/es_systems.cfg.bak"
    xmlstarlet sel -D -I \
        -t -m "/" -e "systemList" \
        -m "//system" -s A:T:U "${field}" -c "." \
        "/etc/emulationstation/es_systems.cfg.bak" >"/etc/emulationstation/es_systems.cfg"
}

function _add_system_emulationstation() {
    local fullname="$1"
    local name="$2"
    local path="$3"
    local extension="$4"
    local command="$5"
    local platform="$6"
    local theme="$7"

    local conf="/etc/emulationstation/es_systems.cfg"
    mkdir -p "/etc/emulationstation"
    if [[ ! -f "${conf}" ]]; then
        echo "<systemList />" >"${conf}"
    fi

    cp "${conf}" "${conf}.bak"
    if [[ $(xmlstarlet sel -t -v "count(/systemList/system[name='${name}'])" "${conf}") -eq 0 ]]; then
        xmlstarlet ed -L -s "/systemList" -t elem -n "system" -v "" \
            -s "/systemList/system[last()]" -t elem -n "name" -v "${name}" \
            -s "/systemList/system[last()]" -t elem -n "fullname" -v "${fullname}" \
            -s "/systemList/system[last()]" -t elem -n "path" -v "${path}" \
            -s "/systemList/system[last()]" -t elem -n "extension" -v "${extension}" \
            -s "/systemList/system[last()]" -t elem -n "command" -v "${command}" \
            -s "/systemList/system[last()]" -t elem -n "platform" -v "${platform}" \
            -s "/systemList/system[last()]" -t elem -n "theme" -v "${theme}" \
            "${conf}"
    else
        xmlstarlet ed -L \
            -u "/systemList/system[name='${name}']/fullname" -v "${fullname}" \
            -u "/systemList/system[name='${name}']/path" -v "${path}" \
            -u "/systemList/system[name='${name}']/extension" -v "${extension}" \
            -u "/systemList/system[name='${name}']/command" -v "${command}" \
            -u "/systemList/system[name='${name}']/platform" -v "${platform}" \
            -u "/systemList/system[name='${name}']/theme" -v "${theme}" \
            "${conf}"
    fi

    # Alert The User If They Have A Custom "es_systems.cfg" Which Doesn't Contain The System We Are Adding
    local conf_local="${configdir}/all/emulationstation/es_systems.cfg"
    if [[ -f "${conf_local}" ]] && [[ "$(xmlstarlet sel -t -v "count(/systemList/system[name='${name}'])" "${conf_local}")" -eq 0 ]]; then
        md_ret_info+=("You Have A Custom Override Of The EmulationStation System Config In:\n\n${conf_local}\n\nYou Will Need To Copy The Updated ${system} Config From ${conf} To Your Custom Config For ${system} To Show Up In EmulationStation.")
    fi

    _sort_systems_emulationstation "name"
}

function _del_system_emulationstation() {
    local fullname="$1"
    local name="$2"
    if [[ -f "/etc/emulationstation/es_systems.cfg" ]]; then
        xmlstarlet ed -L -P -d "/systemList/system[name='${name}']" "/etc/emulationstation/es_systems.cfg"
    fi
}

function _add_rom_emulationstation() {
    local system_name="$1"
    local system_fullname="$2"
    local path="./$3"
    local name="$4"
    local desc="$5"
    local image="$6"

    local config_dir="${configdir}/all/emulationstation"

    mkUserDir "${config_dir}"
    mkUserDir "${config_dir}/gamelists"
    mkUserDir "${config_dir}/gamelists/${system_name}"
    local config="${config_dir}/gamelists/${system_name}/gamelist.xml"

    if [[ ! -f "${config}" ]]; then
        echo "<gameList />" >"${config}"
    fi

    if [[ $(xmlstarlet sel -t -v "count(/gameList/game[path='${path}'])" "${config}") -eq 0 ]]; then
        xmlstarlet ed -L -s "/gameList" -t elem -n "game" -v "" \
            -s "/gameList/game[last()]" -t elem -n "path" -v "${path}" \
            -s "/gameList/game[last()]" -t elem -n "name" -v "${name}" \
            -s "/gameList/game[last()]" -t elem -n "desc" -v "${desc}" \
            -s "/gameList/game[last()]" -t elem -n "image" -v "${image}" \
            "${config}"
    else
        xmlstarlet ed -L \
            -u "/gameList/game[name='${name}']/path" -v "${path}" \
            -u "/gameList/game[name='${name}']/name" -v "${name}" \
            -u "/gameList/game[name='${name}']/desc" -v "${desc}" \
            -u "/gameList/game[name='${name}']/image" -v "${image}" \
            "${config}"
    fi
    chown "${user}:${user}" "${config}"
}

function depends_emulationstation() {
    local depends=(
        'cmake'
        'curl'
        'freeimage'
        'freetype2'
        'libsm'
        'ninja'
        'rapidjson'
        'sdl2'
        'vlc'
    )
    isPlatform "x11" && depends+=('mesa-utils')
    getDepends "${depends[@]}"
}

function sources_emulationstation() {
    gitPullOrClone
}

function build_emulationstation() {
    local params=('-DFREETYPE_INCLUDE_DIRS=/usr/include/freetype2/')

    if isPlatform "rpi"; then
        params+=('-DRPI=On')
        # Use OpenGL on RPI/KMS
        isPlatform "mesa" && params+=('-DGL=On')
    fi

    isPlatform "x11" || isPlatform "wayland" && params+=('-DUSE_GL21=On')

    rpSwap on 1000
    cmake . \
        -GNinja \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        "${params[@]}" \
        -Wno-dev
    ninja clean
    ninja
    rpSwap off
    md_ret_require="${md_build}/emulationstation"
}

function install_emulationstation() {
    md_ret_files=(
        'CREDITS.md'
        'emulationstation.sh'
        'emulationstation'
        'GAMELISTS.md'
        'README.md'
        'resources'
        'THEMES.md'
    )
}

function init_input_emulationstation() {
    local es_config
    es_config="$(_get_input_cfg_emulationstation)"

    # If There Is No ES Config Create It With Initial "inputList" Element
    if [[ ! -s "${es_config}" ]]; then
        echo "<inputList />" >"${es_config}"
    fi

    # Add Or Update "inputconfiguration.sh" "inputAction"
    if [[ $(xmlstarlet sel -t -v "count(/inputList/inputAction[@type='onfinish'])" "${es_config}") -eq 0 ]]; then
        xmlstarlet ed -L -S \
            -s "/inputList" -t elem -n "inputActionTMP" -v "" \
            -s "//inputActionTMP" -t attr -n "type" -v "onfinish" \
            -s "//inputActionTMP" -t elem -n "command" -v "${md_inst}/scripts/inputconfiguration.sh" \
            -r "//inputActionTMP" -v "inputAction" "${es_config}"
    else
        xmlstarlet ed -L \
            -u "/inputList/inputAction[@type='onfinish']/command" -v "${md_inst}/scripts/inputconfiguration.sh" \
            "${es_config}"
    fi

    chown "${user}:${user}" "${es_config}"
}

function copy_inputscripts_emulationstation() {
    mkdir -p "${md_inst}/scripts"

    cp -r "${scriptdir}/scriptmodules/${md_type}/emulationstation/"* "${md_inst}/scripts/"
    chmod +x "${md_inst}/scripts/inputconfiguration.sh"
}

function install_launch_emulationstation() {
    cat > /usr/bin/emulationstation << _EOF_
#!/bin/bash

if [[ \$(id -u) -eq 0 ]]; then
    echo "EmulationStation should not be run as root. If you used "sudo emulationstation" please run without sudo."
    exit 1
fi

if [[ "\$(uname -m)" != x86_64 ]]; then
    if [[ -n "\$(pidof X)" ]]; then
        echo "X is running. Please shut down X in order to mitigate problems with losing keyboard input. For example, logout from LXDE."
        exit 1
    fi
fi

# Save Current TTY/VT Number For Use With X So It Can Be Launched On The Correct TTY
TTY=\$(tty)
export TTY="\${TTY:8:1}"

clear
tput civis
"${md_inst}/emulationstation.sh" "\$@"
if [[ \$? -eq 139 ]]; then
    dialog --cr-wrap --no-collapse --msgbox "EmulationStation crashed!\n\nIf this is your first boot of ArchyPie, make sure you are using the correct image for your system.\n\\nCheck your rom file/folder permissions and if running on a Raspberry Pi, make sure your gpu_split is set high enough and/or switch back to using the Carbon theme." 20 60 >/dev/tty
fi
tput cnorm
_EOF_
    chmod +x "/usr/bin/emulationstation"

    if isPlatform "x11" || isPlatform "wayland"; then
        mkdir -p /usr/share/{icons,applications}
        cp "${scriptdir}/scriptmodules/${md_type}/emulationstation/retropie.svg" "/usr/share/icons/"
        cat > /usr/share/applications/archypie.desktop << _EOF_
[Desktop Entry]
Type=Application
Exec=${TERM_PROGRAM} emulationstation
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[de_DE]=ArchyPie
Name=ArchyPie
Comment[de_DE]=ArchyPie
Comment=archypie
Icon=/usr/share/icons/retropie.svg
Categories=Game
_EOF_
    fi
}

function clear_input_emulationstation() {
    rm "$(_get_input_cfg_emulationstation)"
    init_input_emulationstation
}

function remove_emulationstation() {
    rm -f "/usr/bin/emulationstation"
    if isPlatform "x11" || isPlatform "wayland"; then
        rm -rfv "/usr/share/icons/retropie.svg" "/usr/share/applications/archypie.desktop"
    fi
}

function configure_emulationstation() {
    moveConfigDir "${home}/.emulationstation" "${configdir}/all/emulationstation"

    if [[ "${md_mode}" == "install" ]]; then
        init_input_emulationstation

        copy_inputscripts_emulationstation

        install_launch_emulationstation

        mkdir -p "/etc/emulationstation"

        rp_callModule esthemes install_theme

        addAutoConf "es_swap_a_b" 0
        addAutoConf "disable" 0
    fi
}

function gui_emulationstation() {
    local es_swap=0
    getAutoConf "es_swap_a_b" && es_swap=1

    local disable=0
    getAutoConf "disable" && disable=1

    local default
    local options
    while true; do
        local options=(
            1 "Clear/Reset EmulationStation Input Configuration"
        )

        if [[ "${disable}" -eq 0 ]]; then
            options+=(2 "Auto Configuration (Currently: Enabled)")
        else
            options+=(2 "Auto Configuration (Currently: Disabled)")
        fi

        if [[ "${es_swap}" -eq 0 ]]; then
            options+=(3 "Swap A/B Buttons in ES (Currently: Default)")
        else
            options+=(3 "Swap A/B Buttons in ES (Currently: Swapped)")
        fi

        local cmd=(dialog --backtitle "${__backtitle}" --default-item "${default}" --menu "Choose An Option" 22 76 16)
        local choice
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "${choice}" ]] && break
        default="${choice}"

        case "${choice}" in
            1)
                if dialog --defaultno --yesno "Are you sure you want to reset the EmulationStation controller configuration? This will wipe all controller configs for ES and it will prompt to reconfigure on next start." 22 76 2>&1 >/dev/tty; then
                    clear_input_emulationstation
                    printMsgs "dialog" "$(_get_input_cfg_emulationstation) has been reset to default values."
                fi
                ;;
            2)
                disable="$((disable ^ 1))"
                setAutoConf "disable" "${disable}"
                ;;
            3)
                es_swap="$((es_swap ^ 1))"
                setAutoConf "es_swap_a_b" "${es_swap}"
                local ra_swap="false"
                getAutoConf "es_swap_a_b" && ra_swap="true"
                iniSet "menu_swap_ok_cancel_buttons" "${ra_swap}" "${configdir}/all/retroarch.cfg"
                printMsgs "dialog" "You will need to reconfigure you controller in EmulationStation for the changes to take effect."
                ;;
        esac
    done
}
