#!/bin/bash

################################################################################
# This file is part of the ArchyPie Project                                    #
#                                                                              #
# Please see the LICENSE file at the top-level directory of this distribution. #
################################################################################

rp_module_id="archypiemenu"
rp_module_desc="ArchyPie Menu: Configuration Menu for EmulationStation"
rp_module_section="core"
rp_module_flags="nonet"

function _update_hook_archypiemenu() {
    if ! rp_isInstalled "${md_id}" && [[ -f "${home}/.emulationstation/gamelists/archypie/gamelist.xml" ]]; then
        mkdir -p "${md_inst}"
    fi
}

function depends_archypiemenu() {
    local depends=(
        'mc'
        'p7zip'
    )
    getDepends "${depends[@]}"
}

function install_bin_archypiemenu() {
    return
}

function configure_archypiemenu() {
    if [[ "${md_mode}" == "install" ]]; then
        local rpdir="${home}/ArchyPie/archypiemenu"
        mkdir -p "${rpdir}"
        cp -Rv "${md_data}/icons" "${rpdir}/"
        chown -R "${__user}":"${__group}" "${rpdir}"

        # Add games list & icons
        local files=(
            'audiosettings'
            'bluetooth'
            'configedit'
            'esthemes'
            'filemanager'
            'retroarch'
            'retronetplay'
            'arpisetup'
            'runcommand'
            'showip'
            'splashscreen'
            'wifi'
        )

        local names=(
            'Audio'
            'Bluetooth'
            'Configuration Editor'
            'ES Themes'
            'File Manager'
            'Retroarch'
            'RetroArch Net Play'
            'ArchyPie Setup'
            'Run Command Configuration'
            'Show IP'
            'Splash Screens'
            'Wi-Fi'
        )

        local descs=(
            'Configure audio settings. Choose default of auto, 3.5mm jack, or HDMI. Mixer controls, & apply default settings.'
            'Register & connect to Bluetooth devices. Unregister & remove devices, & display registered & connected devices.'
            'Change common RetroArch options, & manually edit RetroArch configs, global configs, & non-RetroArch configs.'
            'Install, uninstall, or update EmulationStation themes. Most themes can be previewed at https://retropie.org.uk/docs/Themes/.'
            'Basic ASCII file manager for Linux allowing you to browse, copy, delete, & move files.'
            'Launches the RetroArch GUI so you can change RetroArch options. Note: Changes will not be saved unless you have enabled the "Save Configuration On Exit" option.'
            'Set up RetroArch Netplay options, choose host or client, port, host IP, delay frames, & your nickname.'
            'Install ArchyPie from binary or source, install experimental packages, additional drivers, edit Samba shares, custom scraper, as well as other ArchyPie-related configurations.'
            'Change what appears on the runcommand screen. Enable or disable the menu, enable or disable box art, & change CPU configuration.'
            'Displays your current IP address, as well as other information provided by the command "ip addr show."'
            'Enable or disable the splashscreen on ArchyPie boot. Choose a splashscreen, download new splashscreens, and return splashscreen to default.'
            'Connect to or disconnect from a Wi-Fi network & configure Wi-Fi settings.'
        )

        setESSystem "ArchyPie" "archypie" "${rpdir}" ".rp .sh" "sudo ${scriptdir}/archypie_packages.sh archypiemenu launch %ROM%" "" "archypie"

        local file
        local name
        local desc
        local image
        local i
        for i in "${!files[@]}"; do
            case "${files[i]}" in
                audiosettings|splashscreen)
                    ! isPlatform "rpi" && continue
                    ;;
            esac

            file="${files[i]}"
            name="${names[i]}"
            desc="${descs[i]}"
            image="${home}/ArchyPie/archypiemenu/icons/${files[i]}.png"

            touch "${rpdir}/${file}.rp"

            local function
            for function in $(compgen -A function _add_rom_); do
                "${function}" "archypie" "ArchyPie" "${file}.rp" "${name}" "${desc}" "${image}"
            done
        done
    fi
}

function remove_archypiemenu() {
    rm -rf "${home}/ArchyPie/archypiemenu"
    rm -rf "${home}/.emulationstation/gamelists/archypie"
    delSystem archypie
}

function launch_archypiemenu() {
    clear
    local command="${1}"
    local basename="${command##*/}"
    local no_ext="${basename%.rp}"
    joy2keyStart
    case "${basename}" in
        retroarch.rp)
            joy2keyStop
            cp "${configdir}/all/retroarch.cfg" "${configdir}/all/retroarch.cfg.bak"
            chown "${__user}":"${__group}" "${configdir}/all/retroarch.cfg.bak"
            su "${__user}" -c "XDG_RUNTIME_DIR=/run/user/${SUDO_UID} \"${emudir}/retroarch/bin/retroarch\" --menu --config \"${configdir}/all/retroarch.cfg\""
            iniConfig " = " '"' "${configdir}/all/retroarch.cfg"
            iniSet "config_save_on_exit" "false"
            ;;
        arpisetup.rp)
            rp_callModule setup gui
            ;;
        filemanager.rp)
            mc
            ;;
        showip.rp)
            local ip="$(getIPAddress)"
            printMsgs "dialog" "Your IP address is: ${ip:-(unknown)}\n\nOutput of 'ip addr show':\n\n$(ip addr show)"
            ;;
        *.rp)
            rp_callModule ${no_ext} depends
            if fnExists gui_${no_ext}; then
                rp_callModule ${no_ext} gui
            else
                rp_callModule ${no_ext} configure
            fi
            ;;
        *.sh)
            cd "${home}/ArchyPie/archypie" || exit
            sudo -u "${__user}" bash "${command}"
            ;;
    esac
    joy2keyStop
    clear
}
