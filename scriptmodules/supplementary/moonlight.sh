#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="moonlight"
rp_module_desc="Moonlight Embedded: Open Source Gamestream Client For Embedded Systems"
rp_module_help="ROM Extensions: .ml\n\nCopy Moonlight Launch Configurations To: ${romdir}/steam\n\nUse The Configuration Menu For Pairing/Unpairing To/From A Remote Machine"
rp_module_licence="GPL3 https://raw.githubusercontent.com/irtimmer/moonlight-embedded/master/LICENSE"
rp_module_repo="git https://github.com/irtimmer/moonlight-embedded.git master"
rp_module_section="exp"
rp_module_flags="!all arm"

function _scriptmodule_cfg_file_moonlight() {
    echo "${configdir}/all/moonlight/scriptmodule.cfg"
}

function _global_cfg_file_moonlight() {
    echo "${configdir}/all/moonlight/global.conf"
}

function _mangle_moonlight() {
    local -r type="$1"
    shift
    case "${type}" in
        1)  # Slugify, Ref: https://gist.github.com/oneohthree/f528c7ae1e701ad990e6
            iconv -c -t ascii//TRANSLIT <<< "$@" |
                sed -r s/[^a-zA-Z0-9]+/-/g |
                sed -r s/^-+\|-+$//g |
                tr "[:upper:]" "[:lower:]"
            ;;
        2)  # Windows-Compatible, Ref: https://stackoverflow.com/a/35352640
            iconv -c -t ascii//TRANSLIT <<< "$@" |
                sed -r s/[\<\>]+/\ /g |
                sed -r s/[\\/\|]+/-/g |
                sed -r s/[:\*\"]+//g
            ;;
        0|*)  # No Mangling, But Replace Invalid '/' With '-'
            sed -r s/\\//-/g <<< "$@"
            ;;
    esac
}

function _mfmt_moonlight() {
    case "$1" in
        1)   echo "SLUGIFY" ;;
        2)   echo "WINDOWS" ;;
        0|*) echo "NONE   " ;;
    esac
}

function _bfmt_moonlight() {
    if [[ "$1" -eq 1 ]]; then echo "YES"; else echo "NO "; fi
}

function depends_moonlight() {
    local depends=(
        'alsa-lib'
        'avahi'
        'cmake'
        'curl'
        'enet'
        'haskell-uuid'
        'libmicrodns'
        'libpulse'
        'openssl'
        'opusfile'
    )
    getDepends "${depends[@]}"
}

function sources_moonlight() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|DEFAULT_CONFIG_DIR \"/.config\"|DEFAULT_CONFIG_DIR \"/ArchyPie/configs\"|g" -i "${md_build}/src/config.c"
}

function build_moonlight() {
    cmake . \
        -B"build" \
        -G"Ninja" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_INSTALL_RPATH="${md_inst}/lib" \
        -DCMAKE_INSTALL_RPATH_USE_LINK_PATH="TRUE" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
}

function install_moonlight() {
    ninja -C build install/strip
}

function configure_moonlight() {
    moveConfigDir "${arpdir}/${md_id}" "${configdir}/all/${md_id}/"

    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "steam"

        mkUserDir "${configdir}/all/${md_id}"

        # Create Config File
        if [[ ! -f "$(_global_cfg_file_moonlight)" ]]; then
            cat > "$(_global_cfg_file_moonlight)" << "_EOF_"
# Global Config File For Moonlight
quitappafter = true
_EOF_
            chown "${user}:${user}" "$(_global_cfg_file_moonlight)"
        fi

        # Create Wrapper For Moonlight
        cat > "${md_inst}/moonlight.sh" << _EOF_
#!/usr/bin/env bash
export XDG_DATA_DIRS=${md_inst}/share
export XDG_CONFIG_DIR=${configdir}/all
export XDG_CACHE_DIR=${configdir}/all
${md_inst}/bin/moonlight "\$@"
_EOF_
        chmod +x "${md_inst}/moonlight.sh"
    fi

    addEmulator 1 "${md_id}" "steam" "${md_inst}/moonlight.sh stream -config %ROM%"

    addSystem "steam" "Steam Game Streaming" ".ml"
}

function get_scriptmodule_cfg_moonlight() {
    local address
    local overwrite=0
    local wipe=0
    local mangle=0

    iniConfig " = " "" "$(_scriptmodule_cfg_file_moonlight)"
    iniGet "address" && address="${ini_value}"
    iniGet "overwrite" && overwrite="${ini_value}"
    iniGet "wipe" && wipe="${ini_value}"
    iniGet "mangle" && mangle="${ini_value}"

    echo "${address};${overwrite};${wipe};${mangle}"
}

function set_scriptmodule_cfg_moonlight() {
    local -r address="$1"
    local -r overwrite="$2"
    local -r wipe="$3"
    local -r mangle="$4"

    [[ -z "${overwrite}" || -z "${wipe}" || -z "${mangle}" ]] && return

    iniConfig " = " "" "$(_scriptmodule_cfg_file_moonlight)"
    if [[ -n "${address}" ]]; then
        iniSet "address" "${address}"
    else
        iniDel "address"
    fi
    iniSet "overwrite" "${overwrite}"
    iniSet "wipe" "${wipe}"
    iniSet "mangle" "${mangle}"

    chown "${user}:${user}" "$(_scriptmodule_cfg_file_moonlight)"
}

function get_resolution_moonlight() {
    local width=0
    local height=0
    local fps=0

    iniConfig " = " "" "$(_global_cfg_file_moonlight)"
    iniGet "width" && width="${ini_value}"
    iniGet "height" && height="${ini_value}"
    iniGet "fps" && fps="${ini_value}"

    if [[ -n "${width}" && -n "${height}" && -n "${fps}" ]]; then
        echo "${width};${height};${fps}"
    else
        echo "0;0;0"
    fi
}

function get_host_moonlight() {
    local sops="true"
    local unsupported="false"

    iniConfig " = " "" "$(_global_cfg_file_moonlight)"
    iniGet "sops" && sops="${ini_value}"
    iniGet "unsupported" && unsupported="${ini_value}"

    if [[ -n "${sops}" && -n "${unsupported}" ]]; then
        echo "${sops};${unsupported}"
    else
        echo "true;false"
    fi
}

function set_host_moonlight() {
    local -r sops="$1"
    local -r unsupported="$2"

    [[ -z "${sops}" || -z "${unsupported}" ]] && return

    iniConfig " = " "" "$(_global_cfg_file_moonlight)"
    iniSet "sops" "${sops}"
    iniSet "unsupported" "${unsupported}"

    chown "${user}:${user}" "$(_global_cfg_file_moonlight)"
}


function set_resolution_moonlight() {
    local -r width="$1"
    local -r height="$2"
    local -r fps="$3"

    [[ -z "${width}" || -z "${height}" || -z "${fps}" ]] && return

    iniConfig " = " "" "$(_global_cfg_file_moonlight)"
    if [[ "${width}" -gt 0 && "${height}" -gt 0 && "${fps}" -gt 0 ]]; then
        iniSet "width" "${width}"
        iniSet "height" "${height}"
        iniSet "fps" "${fps}"
    else
        iniDel "width"
        iniDel "height"
        iniDel "fps"
    fi

    chown "${user}:${user}" "$(_global_cfg_file_moonlight)"
}

function get_bitrate_moonlight() {
    local bitrate=0

    iniConfig " = " "" "$(_global_cfg_file_moonlight)"
    iniGet "bitrate" && bitrate="${ini_value}"

    if [[ -n "${bitrate}" ]]; then
        echo "${bitrate}"
    else
        echo "0"
    fi
}

function set_bitrate_moonlight() {
    local -r bitrate="$1"

    [[ -z "${bitrate}" ]] && return

    iniConfig " = " "" "$(_global_cfg_file_moonlight)"
    if [[ "${bitrate}" -gt 0 ]]; then
        iniSet "bitrate" "${bitrate}"
    else
        iniDel "bitrate"
    fi

    chown "${user}:${user}" "$(_global_cfg_file_moonlight)"
}

function exec_moonlight() {
    trap "trap INT; echo; return" INT
    sudo -u "${user}" "${md_inst}/moonlight.sh" "$@"
    trap INT
}

function pair_moonlight() {
    exec_moonlight pair "$@"
}

function unpair_moonlight() {
    exec_moonlight unpair "$@"
}

function list_moonlight() {
    exec_moonlight list "$@"
}

function clear_pairing_moonlight() {
    rm -rf "${configdir}/all/moonlight"/{client*,key*,uniqueid.dat}
}

function gen_configs_moonlight() {
    local apps=()
    local app
    local fname
    local config

    # Read Scriptmodule Config
    IFS=";" read -r -a config < <(get_scriptmodule_cfg_moonlight)

    if [[ "${config[2]}" -eq 1 ]]; then
        printMsgs "console" "Wiping Existing Config Files ..."
        rm -f "${romdir}/steam/"*.ml
    fi

    # Iterate Over All Apps In Remote Host
    mapfile -t apps < <(list_moonlight ${config[0]:+"${config[0]}"} | sed -nE 's/^[0-9]+\. //gp')
    for app in "${apps[@]}"; do
        if [[ "${app}" == "." || "${app}" == ".." ]]; then
            printMsgs "console" "Warning: App Name '${app}' Is Not Valid"
            continue
        fi
        fname="$(_mangle_moonlight "${config[3]}" "${app}")"
        [[ "${config[1]}" -eq 0 && -f "${romdir}/steam/${fname}.ml" ]] && continue

        # Generate Config File With Defaults
        printMsgs "console" "Generating Config File For '${app}' ..."
        iniConfig " = " "" "${romdir}/steam/${fname}.ml"
        iniSet "config" "$(_global_cfg_file_moonlight)"
        [[ -n "${config[0]}" ]] && iniSet "address" "${config[0]}"
        iniSet "app" "${app}"
        chown "${user}:${user}" "${romdir}/steam/${fname}.ml" 2>/dev/null
    done
}

function apps_gui_moonlight() {
    local choice
    local cmd
    local config
    local default
    local options=()

    # Read Scriptmodule Config
    IFS=";" read -r -a config < <(get_scriptmodule_cfg_moonlight)

    # Start The Menu GUI
    default="O"
    while true; do
        # Create Menu Options
        options=(
            O "Overwrite Existing Config Files: $(_bfmt_moonlight ${config[1]})" "Overwrite Existing Files In '${romdir}/steam'?"
            W "Wipe Existing Config Files: $(_bfmt_moonlight ${config[2]})" "Delete All Files In '${romdir}/steam'?"
            S "Config Filename Mangling: $(_mfmt_moonlight ${config[3]})" "Use Original App Names, Slugified Names Or Windows Compatible Names?"
            G "Generate Config Files" "Start Remote Apps Config Files Generation"
        )

        # show main menu
        cmd=(dialog --backtitle "${__backtitle}" --default-item "${default}" --item-help --menu "Remote Apps" 13 60 16)
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        default="${choice}"
        case "${choice}" in
            O)
                config[1]=$((1 - config[1]))
                set_scriptmodule_cfg_moonlight "${config[@]}"
                ;;
            W)
                config[2]=$((1 - config[2]))
                set_scriptmodule_cfg_moonlight "${config[@]}"
                ;;
            S)
                config[3]=$((config[3] + 1))
                [[ "${config[3]}" -gt 2 ]] && config[3]=0
                set_scriptmodule_cfg_moonlight "${config[@]}"
                ;;
            G)
                gen_configs_moonlight
                read -p "Press ENTER To Continue... "
                ;;
            *)
                break
                ;;
        esac
    done
}

function host_gui_moonlight() {
    local choice
    local cmd
    local default
    local options=()
    local tuple

    # Get Current Host Options
    IFS=";" read -r -a tuple < <(get_host_moonlight)
    default="U"
    [[ "${tuple[0]}" == "false" && "${tuple[1]}" == "false" ]] && default="1"
    [[ "${tuple[0]}" == "true"  && "${tuple[1]}" == "true"  ]] && default="2"
    [[ "${tuple[0]}" == "false" && "${tuple[1]}" == "true"  ]] && default="3"

    # Create Menu Options
    options=(
        U "Unset (Use Default)" "Do Not Force Host Compatibility Settings"
        1 "No SOPS" "Do Not Allow GFE To Modify Game Settings"
        2 "Allow Unsupported" "Try Streaming If GFE Version Or Options Are Unsupported"
        3 "Open Source Host Compatibility" "Turn Off SOPS & Allow Unsupported Options (Sunshine/Open-Stream GFE Server)"
    )

    # Show Main Menu
    cmd=(dialog --backtitle "${__backtitle}" --default-item "${default}" --item-help --menu "Host Compatibility Options" 16 45 16)
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    case "${choice}" in
        U)
            set_host_moonlight "true" "false"
            ;;
        1)
            set_host_moonlight "false" "false"
            ;;
        2)
            set_host_moonlight "true" "true"
            ;;
        3)
            set_host_moonlight "false" "true"
            ;;
    esac
}

function resolution_gui_moonlight() {
    local choice
    local cmd
    local default
    local options=()
    local resolution

    # Get Current Resolution
    IFS=";" read -r -a resolution < <(get_resolution_moonlight)
    if [[ "${resolution[0]}" -gt 0 && "${resolution[1]}" -gt 0 && "${resolution[2]}" -gt 0 ]]; then
        default="C"
        [[ "${resolution[0]}" == 1920 && "${resolution[1]}" == 1080 && "${resolution[2]}" == 60 ]] && default="1"
        [[ "${resolution[0]}" == 1920 && "${resolution[1]}" == 1080 && "${resolution[2]}" == 30 ]] && default="2"
        [[ "${resolution[0]}" == 1280 && "${resolution[1]}" == 720 && "${resolution[2]}" == 60 ]] && default="3"
        [[ "${resolution[0]}" == 1280 && "${resolution[1]}" == 720 && "${resolution[2]}" == 30 ]] && default="4"
        resolution="${resolution[0]} x ${resolution[1]} @ ${resolution[2]} fps"
    else
        default="U"
        resolution="(using default)"
    fi

    # Create Menu Options
    options=(
        U "Unset (Use Default)" "Do Not Force A Resolution Setting"
        1 "1080p60" "Set Resolution To 1920 x 1080 @ 60 fps"
        2 "1080p30" "Set Resolution To 1920 x 1080 @ 30 fps"
        3 "720p60"  "Set Resolution To 1280 x 720 @ 60 fps"
        4 "720p30"  "Set Resolution To 1280 x 720 @ 30 fps"
        C "Custom"  "Set A Custom Resolution"
    )

    # Show Main Menu
    cmd=(dialog --backtitle "${__backtitle}" --default-item "${default}" --item-help --menu "Global Resolution\nCurrent: ${resolution}" 16 45 16)
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    case "${choice}" in
        U)
            set_resolution_moonlight "0" "0" "0"
            ;;
        1)
            set_resolution_moonlight "1920" "1080" "60"
            ;;
        2)
            set_resolution_moonlight "1920" "1080" "30"
            ;;
        3)
            set_resolution_moonlight "1280" "720" "60"
            ;;
        4)
            set_resolution_moonlight "1280" "720" "30"
            ;;
        C)
            cmd=(dialog --backtitle "${__backtitle}" --inputbox "Please Enter A Custom Resolution As WIDTH HEIGHT FPS (Separated By Spaces)" 10 50)
            choice=$("${cmd[@]}" 2>&1 >/dev/tty)
            if [[ $? -eq 0 ]]; then
                IFS=" " read -r -a choice <<< "${choice}"
                set_resolution_moonlight "${choice[0]}" "${choice[1]}" "${choice[2]}"
            fi
            ;;
    esac
}

function bitrate_gui_moonlight() {
    local bitrate
    local choice
    local cmd
    local default
    local options=()

    # Get Current Bitrate
    bitrate=$(get_bitrate_moonlight)
    if [[ "${bitrate}" -gt 0 ]]; then
        default="C"
        [[ "${bitrate}" == 20000 ]] && default="1"
        [[ "${bitrate}" == 10000 ]] && default="2"
        [[ "${bitrate}" == 5000 ]] && default="3"
        bitrate="${bitrate} Kbps"
    else
        default="U"
        bitrate="(Using Default)"
    fi

    # Create Menu Options
    options=(
        U "Unset (Use Default)" "Do Not Force A Stream Bitrate Setting"
        1 "20000"  "Set Stream Bitrate To 20000 Kbps"
        2 "10000"  "Set Stream Bitrate To 10000 Kbps"
        3 "5000"   "Set Stream Bitrate To 5000 Kbps"
        C "Custom" "Set A Custom Stream Bitrate"
    )

    # show main menu
    cmd=(dialog --backtitle "${__backtitle}" --default-item "${default}" --item-help --menu "Stream Bitrate\nCurrent: ${bitrate}" 16 45 16)
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    case "${choice}" in
        U)
            set_bitrate_moonlight "0"
            ;;
        1)
            set_bitrate_moonlight "20000"
            ;;
        2)
            set_bitrate_moonlight "10000"
            ;;
        3)
            set_bitrate_moonlight "5000"
            ;;
        C)
            cmd=(dialog --backtitle "${__backtitle}" --inputbox "Please Enter A Custom Stream Bitrate In Kbps" 10 50)
            choice=$("${cmd[@]}" 2>&1 >/dev/tty)
            [[ $? -eq 0 ]] && set_bitrate_moonlight "${choice}"
            ;;
    esac
}

function gui_moonlight() {
    local choice
    local cmd
    local config
    local default
    local options=()

    # Read Scriptmodule Config
    IFS=";" read -r -a config < <(get_scriptmodule_cfg_moonlight)

    # Start The Menu GUI
    default="A"
    while true; do
        # Create Menu Options, If No Address Show 'autodiscover'
        options=(
            A "Set Remote Host Address (${config[0]:-autodiscover})"
            P "Pair To Remote Host"
            U "Unpair From Remote Host"
            G "Configure Remote Apps"
            R "Configure Global Resolution"
            B "Configure Global Stream Bitrate"
            H "Configure Host Compatibility"
            C "Clear All Pairing Data"
        )

        # Show Main Menu
        cmd=(dialog --backtitle "${__backtitle}" --default-item "${default}" --menu "Choose An Option" 16 60 16)
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        default="${choice}"
        case "${choice}" in
            A)
                cmd=(dialog --backtitle "${__backtitle}" --inputbox "Please Enter The Address Of The Remote Host (Leave BLANK For Autodiscovery Of The Remote Host)" 10 65)
                choice=$("${cmd[@]}" 2>&1 >/dev/tty)
                if [[ $? -eq 0 ]]; then
                    config[0]="${choice}"
                    set_scriptmodule_cfg_moonlight "${config[@]}"
                fi
                ;;
            P)
                pair_moonlight ${config[0]:+"${config[0]}"} </dev/tty >/dev/tty
                read -p "Press ENTER To Continue ... "
                ;;
            U)
                unpair_moonlight ${config[0]:+"${config[0]}"} </dev/tty >/dev/tty
                read -p "Press ENTER To Continue ... "
                ;;
            G)
                apps_gui_moonlight
                ;;
            R)
                resolution_gui_moonlight
                ;;
            B)
                bitrate_gui_moonlight
                ;;
            H)
                host_gui_moonlight
                ;;
            C)
                if dialog --defaultno --yesno "Are You Sure You Want To CLEAR ALL Pairing Data?" 8 40 2>&1 >/dev/tty; then
                    if clear_pairing_moonlight; then
                        printMsgs "dialog" "All Pairing Data Cleared"
                    else
                        printMsgs "dialog" "Could Not Clear Pairing Data"
                    fi
                fi
                ;;
            *)
                break
                ;;
        esac
    done
}
