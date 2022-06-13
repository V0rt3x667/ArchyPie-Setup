#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="archypiemenu"
rp_module_desc="ArchyPie Configuration Menu for EmulationStation"
rp_module_section="core"
rp_module_flags="nonet"

function _update_hook_archypiemenu() {
    # to show as installed when upgrading to archypie-setup 4.x
    if ! rp_isInstalled "$md_id" && [[ -f "$home/.emulationstation/gamelists/archypie/gamelist.xml" ]]; then
        mkdir -p "$md_inst"
        # to stop older scripts removing when launching from archypie menu in ES due to not using exec or exiting after running archypie-setup from this module
        touch "$md_inst/.archypie"
    fi
}

function depends_archypiemenu() {
    getDepends mc
}

function install_bin_archypiemenu() {
    return
}

function configure_archypiemenu() {
    [[ "$md_mode" == "remove" ]] && return

    local rpdir="$home/ArchyPie/archypiemenu"
    mkdir -p "$rpdir"
    cp -Rv "$md_data/icons" "$rpdir/"
    chown -R "$user:$user" "$rpdir"

    isPlatform "rpi" && rm -f "$rpdir/dispmanx.rp"

    # add the gameslist / icons
    local files=(
        'audiosettings'
        'bluetooth'
        'configedit'
        'esthemes'
        'filemanager'
        'raspiconfig'
        'retroarch'
        'retronetplay'
        'rpsetup'
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
        'Raspi-Config'
        'Retroarch'
        'RetroArch Net Play'
        'ArchyPie Setup'
        'Run Command Configuration'
        'Show IP'
        'Splash Screens'
        'WiFi'
    )

    local descs=(
        'Configure audio settings. Choose default of auto, 3.5mm jack, or HDMI. Mixer controls, and apply default settings.'
        'Register and connect to Bluetooth devices. Unregister and remove devices, and display registered and connected devices.'
        'Change common RetroArch options, and manually edit RetroArch configs, global configs, and non-RetroArch configs.'
        'Install, uninstall, or update EmulationStation themes. Most themes can be previewed at https://retropie.org.uk/docs/Themes/.'
        'Basic ASCII file manager for Linux allowing you to browse, copy, delete, and move files.'
        'Change user password, boot options, internationalization, camera, add your Pi to Rastrack, overclock, overscan, memory split, SSH and more.'
        'Launches the RetroArch GUI so you can change RetroArch options. Note: Changes will not be saved unless you have enabled the "Save Configuration On Exit" option.'
        'Set up RetroArch Netplay options, choose host or client, port, host IP, delay frames, and your nickname.'
        'Install ArchyPie from binary or source, install experimental packages, additional drivers, edit Samba shares, custom scraper, as well as other ArchyPie-related configurations.'
        'Change what appears on the runcommand screen. Enable or disable the menu, enable or disable box art, and change CPU configuration.'
        'Displays your current IP address, as well as other information provided by the command "ip addr show."'
        'Enable or disable the splashscreen on ArchyPie boot. Choose a splashscreen, download new splashscreens, and return splashscreen to default.'
        'Connect to or disconnect from a WiFi network and configure WiFi settings.'
    )

    setESSystem "ArchyPie" "archypie" "$rpdir" ".rp .sh" "sudo $scriptdir/archypie_packages.sh archypiemenu launch %ROM% </dev/tty >/dev/tty" "" "archypie"

    local file
    local name
    local desc
    local image
    local i
    for i in "${!files[@]}"; do
        case "${files[i]}" in
            audiosettings|raspiconfig|splashscreen)
                ! isPlatform "rpi" && continue
                ;;
        esac

        file="${files[i]}"
        name="${names[i]}"
        desc="${descs[i]}"
        image="$home/ArchyPie/archypiemenu/icons/${files[i]}.png"

        touch "$rpdir/$file.rp"

        local function
        for function in $(compgen -A function _add_rom_); do
            "$function" "archypie" "ArchyPie" "$file.rp" "$name" "$desc" "$image"
        done
    done
}

function remove_archypiemenu() {
    rm -rf "$home/ArchyPie/archypiemenu"
    rm -rf "$home/.emulationstation/gamelists/archypie"
    delSystem archypie
}

function launch_archypiemenu() {
    clear
    local command="$1"
    local basename="${command##*/}"
    local no_ext="${basename%.rp}"
    joy2keyStart
    case "$basename" in
        retroarch.rp)
            joy2keyStop
            cp "$configdir/all/retroarch.cfg" "$configdir/all/retroarch.cfg.bak"
            chown "$user:$user" "$configdir/all/retroarch.cfg.bak"
            su "$user" -c "XDG_RUNTIME_DIR=/run/user/$SUDO_UID \"$emudir/retroarch/bin/retroarch\" --menu --config \"$configdir/all/retroarch.cfg\""
            iniConfig " = " '"' "$configdir/all/retroarch.cfg"
            iniSet "config_save_on_exit" "false"
            ;;
        rpsetup.rp)
            rp_callModule setup gui
            ;;
        raspiconfig.rp)
            raspi-config
            ;;
        filemanager.rp)
            mc
            ;;
        showip.rp)
            local ip="$(getIPAddress)"
            printMsgs "dialog" "Your IP is: ${ip:-(unknown)}\n\nOutput of 'ip addr show':\n\n$(ip addr show)"
            ;;
        *.rp)
            rp_callModule "$no_ext" depends
            if fnExists gui_"$no_ext"; then
                rp_callModule "$no_ext" gui
            else
                rp_callModule "$no_ext" configure
            fi
            ;;
        *.sh)
            cd "$home/ArchyPie/archypiemenu" || exit
            sudo -u "$user" bash "$command"
            ;;
    esac
    joy2keyStop
    clear
}
