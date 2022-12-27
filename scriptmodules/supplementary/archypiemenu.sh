#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

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
    local depends=('mc')
    getDepends "${depends[@]}"
}

function install_bin_archypiemenu() {
    return
}

function configure_archypiemenu() {
    if [[ "$md_mode" == "install" ]]; then
        local dir="${home}/ArchyPie/${md_id}"
        mkdir -p "${dir}"
        cp -Rv "${md_data}/icons" "${dir}/"
        chown -R "${user}:${user}" "${dir}"

        # Add Games List & Icons
        local files=(
            'audiosettings'
            'configedit'
            'esthemes'
            'filemanager'
            'retroarch'
            'retronetplay'
            'arpisetup'
            'runcommand'
            'showip'
        )

        local names=(
            'Audio'
            'Configuration Editor'
            'ES Themes'
            'File Manager'
            'Retroarch'
            'RetroArch Net Play'
            'ArchyPie Setup'
            'Run Command Configuration'
            'Show IP'
        )

        local descs=(
            'Configure Audio Settings: Select From Auto, 3.5mm Jack, or HDMI.'
            'Change And Edit RetroArch And Non-RetroArch Options.'
            'Install, Uninstall Or Update EmulationStation Themes.'
            'ASCII File Manager For Linux.'
            'Launches The RetroArch GUI So You Can Change RetroArch Options. Note: Changes Will Not Be Saved Unless You Have Enabled The "Save Configuration On Exit" Option.'
            'Configure RetroArch Netplay Options.'
            'Install ArchyPie Packages, Edit Samba Shares And Other ArchyPie Configurations.'
            'Configure Runcommand, Enable Or Disable The Menu, Enable Or Disable Box Art And Change CPU Configuration.'
            'Displays Your Current IP Address And Other Information Provided By The Command "ip addr show."'
        )

        setESSystem "ArchyPie" "archypie" "${dir}" ".rp .sh" "sudo ${scriptdir}/archypie_packages.sh ${md_id} launch %ROM% </dev/tty >/dev/tty" "" "${md_id}"

        local file
        local name
        local desc
        local image
        local i
        for i in "${!files[@]}"; do
            case "${files[i]}" in
                audiosettings)
                    ! isPlatform "rpi" && continue
                    ;;
            esac

            file="${files[i]}"
            name="${names[i]}"
            desc="${descs[i]}"
            image="${home}/ArchyPie/${md_id}/icons/${files[i]}.png"

            touch "${dir}/${file}.rp"

            local function
            for function in $(compgen -A function _add_rom_); do
                "${function}" "archypie" "ArchyPie" "${file}.rp" "${name}" "${desc}" "${image}"
            done
        done
    fi
}

function remove_archypiemenu() {
    rm -rf "${home}/ArchyPie/${md_id}"
    rm -rf "${home}/.emulationstation/gamelists/archypie"
    delSystem archypie
}

function launch_archypiemenu() {
    clear
    local command="$1"
    local basename="${command##*/}"
    local no_ext="${basename%.rp}"
    joy2keyStart
    case "${basename}" in
        retroarch.rp)
            joy2keyStop
            cp "${configdir}/all/retroarch.cfg" "${configdir}/all/retroarch.cfg.bak"
            chown "${user}:${user}" "${configdir}/all/retroarch.cfg.bak"
            su "${user}" -c "XDG_RUNTIME_DIR=/run/user/${SUDO_USER} \"${emudir}/retroarch/bin/retroarch\" --menu --config \"${configdir}/all/retroarch.cfg\"" > ~/test.txt
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
            local ip
            ip="$(getIPAddress)"
            printMsgs "dialog" "Your IP Is: ${ip:-(unknown)}\n\nOutput Of 'ip addr show':\n\n$(ip addr show)"
            ;;
        *.rp)
            rp_callModule "${no_ext}" depends
            if fnExists gui_"${no_ext}"; then
                rp_callModule "${no_ext}" gui
            else
                rp_callModule "${no_ext}" configure
            fi
            ;;
        *.sh)
            cd "${home}/ArchyPie/${md_id}" || exit
            sudo -u "${user}" bash "${command}"
            ;;
    esac
    joy2keyStop
    clear
}
