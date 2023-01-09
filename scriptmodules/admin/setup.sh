#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="setup"
rp_module_desc="Setup GUI for ArchyPie"
rp_module_section=""

function _setup_gzip_log() {
    setsid tee >(setsid gzip --stdout >"$1")
}

function rps_logInit() {
    if [[ ! -d "$__logdir" ]]; then
        if mkdir -p "$__logdir"; then
            chown "${user}:${user}" "$__logdir"
        else
            fatalError "Couldn't make directory $__logdir"
        fi
    fi

    # Remove All But The Last 20 Logs
    find "${__logdir}" -type f | sort | head -n -20 | xargs -d '\n' --no-run-if-empty rm

    local now
    now=$(date +'%Y-%m-%d_%H%M%S')
    logfilename="${__logdir}/rps_${now}.log.gz"
    touch "${logfilename}"
    chown "${user}:${user}" "${logfilename}"
    time_start=$(date +"%s")
}

function rps_logStart() {
    echo -e "Log Started At: $(date -d @"${time_start}")\n"
    echo "ArchyPie-Setup Version: ${__version} ($(sudo -u "${user}" git -C "${scriptdir}" log -1 --pretty=format:%h))"
    echo "System: ${__platform} (${__platform_arch}) - ${__os_desc} - $(uname -a)"
}

function rps_logEnd() {
    time_end=$(date +"%s")
    echo
    echo "Log Ended At: $(date -d @"${time_end}")"
    date_total=$((time_end-time_start))
    local hours=$((date_total / 60 / 60 % 24))
    local mins=$((date_total / 60 % 60))
    local secs=$((date_total % 60))
    echo "Total Running Time: ${hours} hours, ${mins} mins, ${secs} secs"
}

function rps_printInfo() {
    local log="$1"
    reset
    if [[ ${#__ERRMSGS[@]} -gt 0 ]]; then
        printMsgs "dialog" "${__ERRMSGS[@]}"
        [[ -n "$log" ]] && printMsgs "dialog" "Please see $log for more in depth information regarding the errors."
    fi
    if [[ ${#__INFMSGS[@]} -gt 0 ]]; then
        printMsgs "dialog" "${__INFMSGS[@]}"
    fi
    __ERRMSGS=()
    __INFMSGS=()
}

function depends_setup() {
    # Check For "VERSION" File, If It Does Not Exist The "post_update" Function Will Be Triggered.
    if [[ ! -f "${rootdir}/VERSION" ]]; then
        joy2keyStop
        exec "${scriptdir}/archypie_packages.sh" setup post_update gui_setup
    fi

    # Required For Use With "udev"
    local group
    group="input"
    if ! hasFlag "$(groups "${user}")" "$group"; then
        usermod -a -G "${group}" "${user}"
    fi

    # Set "__setup" To 1 Which Is Used To Adjust Package Function Behaviour If Called From The Setup GUI
    __setup=1

    # Print Any Pending Messages
    rps_printInfo
}

function updatescript_setup() {
    clear
    chown -R "${user}:${user}" "$scriptdir"
    printHeading "Fetching the latest version of the ArchyPie Setup Script."
    pushd "$scriptdir" >/dev/null || exit
    if [[ ! -d ".git" ]]; then
        printMsgs "dialog" "Cannot find directory '.git'. Please clone the ArchyPie Setup Script via 'git clone https://github.com/V0rt3x667/ArchyPie-Setup.git'"
        popd >/dev/null || exit
        return 1
    fi
    local error
    if ! error=$(sudo -u "${user}" git pull --ff-only 2>&1 >/dev/null); then
        printMsgs "dialog" "Update Failed:\n\n$error"
        popd >/dev/null || exit
        return 1
    fi
    popd >/dev/null || exit

    printMsgs "dialog" "Fetched the latest version of the ArchyPie Setup Script."
    return 0
}

function post_update_setup() {
    local return_func=("$@")

    joy2keyStart

    echo "$__version" >"$rootdir/VERSION"

    clear
    local logfilename
    rps_logInit
    {
        rps_logStart
        printHeading "Running Post Update Hooks"
        rp_updateHooks
        rps_logEnd
    } &> >(_setup_gzip_log "$logfilename")
    rps_printInfo "$logfilename"

    printMsgs "dialog" "NOTICE: The ArchyPie-Setup Script is available to download for free from 'https://github.com/V0rt3x667/ArchyPie-Setup.git'\n\nArchyPie includes software that has non-commercial licences. Selling ArchyPie or including ArchyPie with your commercial product is not allowed.\n\nNo copyrighted games are included with ArchyPie.\n\nIf you have been sold this software, you can let us know about it by emailing archypieproject@gmail.com."

    "${return_func[@]}"
}

function package_setup() {
    local id="$1"
    local default=""

    if ! rp_isEnabled "${id}"; then
        printMsgs "dialog" "Sorry but package '${id}' is not available for your system ($__platform)\n\nPackage Flags: ${__mod_info[${id}/flags]}\n\nYour $__platform Flags: ${__platform_flags[*]}"
        return 1
    fi

    declare -A option_msgs=(
        ["U"]=""
        ["B"]="Install from Pre-compiled Binary"
        ["S"]="Install from Source"
    )

    while true; do
        local options=()

        local status

        local has_binary=0
        local has_net=0

        isConnected && has_net=1

        # For modules with nonet flag that don't need to download data, we force has_net to 1, so we get install options
        hasFlag "${__mod_info[${id}/flags]}" "nonet" && has_net=1

        if [[ "$has_net" -eq 1 ]]; then
            dialog --backtitle "$__backtitle" --infobox "Checking for updates for ${id} ..." 3 60 >/dev/tty
            rp_hasBinary "${id}"
            local ret="$?"
            [[ "$ret" -eq 0 ]] && has_binary=1
            [[ "$ret" -eq 2 ]] && has_net=0
        fi

        local is_installed=0

        local pkg_origin=""
        local pkg_date=""
        if ! rp_isInstalled "${id}"; then
            status="Not Installed"
        else
            is_installed=1

            rp_loadPackageInfo "${id}"
            pkg_origin="${__mod_info[${id}/pkg_origin]}"
            pkg_date="${__mod_info[${id}/pkg_date]}"
            [[ -n "$pkg_date" ]] && pkg_date="$(date -u -d "$pkg_date" 2>/dev/null)"

            status="Installed from $pkg_origin"

            [[ -n "$pkg_date" ]] && status+=" (Built: $pkg_date)"

            if [[ "$has_net" -eq 1 ]]; then
                rp_hasNewerModule "${id}" "$pkg_origin"
                local has_newer="$?"
                case "$has_newer" in
                    0)
                        status+="\nUpdate is available."
                        option_msgs["U"]="Update (from $pkg_origin)"
                        ;;
                    1)
                        status+="\nYou are running the latest $pkg_origin."
                        option_msgs["U"]="Re-install (from $pkg_origin)"
                        ;;
                    2)
                        if [[ "$pkg_origin" == "unknown" ]]; then
                            if [[ "$has_binary" -eq 1 ]]; then
                                pkg_origin="binary"
                            else
                                pkg_origin="source"
                            fi
                        fi
                        option_msgs["U"]="Update (from $pkg_origin)"
                        status+="\nUpdate may be available (Unable to check for this package)"
                        ;;
                    3)
                        has_net=0
                        ;;
                esac
            fi
        fi

        if [[ "$has_net" -eq 1 ]]; then
            if [[ "$is_installed" -eq 1 ]]; then
                options+=(U "${option_msgs["U"]}")
            fi

            if [[ "$pkg_origin" != "binary" && "$has_binary" -eq 1 ]]; then
                options+=(B "${option_msgs["B"]}")
            fi

            if [[ "$pkg_origin" != "source" ]] && fnExists "sources_${id}"; then
                options+=(S "${option_msgs[S]}")
           fi
        else
            status+="\nInstall Options Disabled:\n$__NET_ERRMSG"
        fi

        if [[ "$is_installed" -eq 1 ]]; then
            if fnExists "gui_${id}"; then
                options+=(C "Configuration & Options")
            fi
            options+=(X "Remove")
        fi

        if [[ -d "$__builddir/${id}" ]]; then
            options+=(Z "Clean Source Folder")
        fi

        local help="${__mod_info[${id}/desc]}\n\n${__mod_info[${id}/help]}"
        if [[ -n "$help" ]]; then
            options+=(H "Package Help")
        fi

        if [[ "$is_installed" -eq 1 ]]; then
            options+=(V "Package Version Information")
        fi

        cmd=(dialog --backtitle "$__backtitle" --cancel-label "Back" --default-item "$default" --menu "Choose an option for ${id}\n$status" 22 76 16)
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        default="${choice}"
        local logfilename

        case "${choice}" in
            U|B|S)
                dialog --defaultno --yesno "Are you sure you want to ${option_msgs[${choice}]}?" 22 76 2>&1 >/dev/tty || continue
                local mode
                case "${choice}" in
                    U) mode="_auto_" ;;
                    B) mode="_binary_" ;;
                    S) mode="_source_" ;;
                esac
                clear
                rps_logInit
                {
                    rps_logStart
                    rp_installModule "${id}" "$mode"
                    rps_logEnd
                } &> >(_setup_gzip_log "$logfilename")
                rps_printInfo "$logfilename"
                ;;
            C)
                rps_logInit
                {
                    rps_logStart
                    rp_callModule "${id}" gui
                    rps_logEnd
                } &> >(_setup_gzip_log "$logfilename")
                rps_printInfo "$logfilename"
                ;;
            X)
                local text="Are you sure you want to remove ${id}?"
                case "${__mod_info[${id}/section]}" in
                    core)
                        text+="\n\nWARNING! - Core packages are needed for ArchyPie to function!"
                        ;;
                    depends)
                        text+="\n\nWARNING! - This package is required by other ArchyPie packages, removing may cause other packages to fail."
                        text+="\n\nNOTE: This will be reinstalled if missing when updating packages that require it."
                        ;;
                esac
                dialog --defaultno --yesno "$text" 22 76 2>&1 >/dev/tty || continue
                rps_logInit
                {
                    rps_logStart
                    clear
                    rp_callModule "${id}" remove
                    rps_logEnd
                } &> >(_setup_gzip_log "$logfilename")
                rps_printInfo "$logfilename"
                ;;
            H)
                printMsgs "dialog" "$help"
                ;;
            V)
                local info
                rp_loadPackageInfo "${id}"
                read -r -d '' info << _EOF_
Package Origin: ${__mod_info[${id}/pkg_origin]}
Build Date: ${__mod_info[${id}/pkg_date]}

Built from Source:

Type: ${__mod_info[${id}/pkg_repo_type]}
URL: ${__mod_info[${id}/pkg_repo_url]}
Branch: ${__mod_info[${id}/pkg_repo_branch]}
Commit: ${__mod_info[${id}/pkg_repo_commit]}
Date: ${__mod_info[${id}/pkg_repo_date]}
_EOF_
               printMsgs "dialog" "$info"
               ;;
            Z)
                rp_callModule "${id}" clean
                printMsgs "dialog" "$__builddir/${id} has been removed."
                ;;
            *)
                break
                ;;
        esac

    done
}

function section_gui_setup() {
    local section="$1"
    local ids=()
    case "$section" in
        all|inst)
            name="Packages"
            local id
            for id in "${__mod_id[@]}"; do
                # If we are showing installed packaged, skip those that are not installed
                [[ "$section" == "inst" ]] && ! rp_isInstalled "${id}" && continue
                # Don't show packages from depends or modules with no section (admin)
                ! [[ "${__mod_info[${id}/section]}" =~ ^(depends|config|)$ ]] && ids+=("${id}")
            done
            ;;
         *)
            name="${__sections[$section]} Packages"
            ids=($(rp_getSectionIds $section))
            ;;
    esac

    local default=""
    local status=""
    local has_net=1
    while true; do
        local options=()
        local pkgs=()

        status="Please choose a package from the list below."
        if ! isConnected; then
            status+="\nInstall Options Disabled: ($__NET_ERRMSG)"
            has_net=0
        fi

        local id
        local num_pkgs=0
        local info
        local type
        local last_type=""
        for id in "${ids[@]}"; do
            local type="${__mod_info[${id}/vendor]} - ${__mod_info[${id}/type]}"
            # Create a heading for each origin and module type
            if [[ "$last_type" != "${type}" ]]; then
                info="${type}"
                pkgs+=("----" "\Z4$info ----" "Packages from $info")
                last_type="${type}"
            fi
            if ! rp_isEnabled "${id}"; then
                info="\Z1${id}\Zn"
            else
                if rp_isInstalled "${id}"; then
                    rp_loadPackageInfo "${id}" "pkg_origin"
                    local pkg_origin="${__mod_info[${id}/pkg_origin]}"

                    info="${id} (Installed - via $pkg_origin)"
                    ((num_pkgs++))
                else
                    info="${id}"
                fi
            fi
            pkgs+=("${__mod_idx[${id}]}" "$info" "${id} - ${__mod_info[${id}/desc]}"$'\n\n'"${__mod_info[${id}/help]}")
        done

        if [[ "$has_net" -eq 1 && "$num_pkgs" -gt 0 ]]; then
            options+=(U "Update All Installed $name" "This will update any installed $name. The packages will be updated by the method used previously.")
        fi

        # Allow installing an entire section except for drivers and dependencies.
        if [[ "$has_net" -eq 1 && "$section" != "driver" && "$section" != "depends" ]]; then
            # Don't show "Install all packages" when we are showing only installed packages.
            if [[ "$section" != "inst" ]]; then
                options+=(I "Install All $name" "This will install all $name. If a package is not installed and a pre-compiled binary is available it will be used. If a package is already installed, it will be updated by the method used previously.")
            fi
            options+=(X "Remove All Installed $name" "X This will remove all installed $name.")
        fi

        options+=("${pkgs[@]}")

        local cmd=(dialog --colors --backtitle "$__backtitle" --cancel-label "Back" --item-help --help-button --default-item "$default" --menu "$status" 22 76 16)

        local choice
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "${choice}" ]] && break
        if [[ "${choice[@]:0:4}" == "HELP" ]]; then
            # Remove HELP
            choice="${choice[@]:5}"
            # Get ID of menu item
            default="${choice/%\ */}"
            # Remove ID
            choice="${choice#* }"
            printMsgs "dialog" "${choice}"
            continue
        fi

        default="${choice}"

        local logfilename
        case "${choice}" in
            U|I)
                local mode="update"
                [[ "${choice}" == "I" ]] && mode="install"
                dialog --defaultno --yesno "Are you sure you want to $mode all installed $name?" 22 76 2>&1 >/dev/tty || continue
                rps_logInit
                {
                    rps_logStart
                    for id in "${ids[@]}"; do
                        ! rp_isEnabled "${id}" && continue
                        # if we are updating, skip packages that are not installed
                        if [[ "$mode" == "update" ]]; then
                            if rp_isInstalled "${id}"; then
                                rp_installModule "${id}" "_update_"
                            fi
                        else
                            rp_installModule "${id}" "_auto_"
                        fi
                    done
                    rps_logEnd
                } &> >(_setup_gzip_log "$logfilename")
                rps_printInfo "$logfilename"
                ;;
            X)
                local text="Are you sure you want to remove all installed $name?"
                [[ "$section" == "core" ]] && text+="\n\nWARNING! - Core packages are needed for ArchyPie to function!"
                dialog --defaultno --yesno "$text" 22 76 2>&1 >/dev/tty || continue
                rps_logInit
                {
                    rps_logStart
                    for id in "${ids[@]}"; do
                        rp_isInstalled "${id}" && rp_callModule "${id}" remove
                    done
                    rps_logEnd
                } &> >(_setup_gzip_log "$logfilename")
                rps_printInfo "$logfilename"
                ;;
            ----)
                ;;
            *)
                package_setup "${__mod_id[${choice}]}"
                ;;
        esac
    done
}

function config_gui_setup() {
    local default
    while true; do
        local options=()
        local id
        for id in "${__mod_id[@]}"; do
            # Show all configuration modules and any installed packages with a GUI function
            if [[ "${__mod_info[${id}/section]}" == "config" ]] || rp_isInstalled "${id}" && fnExists "gui_${id}"; then
                options+=("${__mod_idx[${id}]}" "${id}  - ${__mod_info[${id}/desc]}" "${__mod_idx[${id}]} ${__mod_info[${id}/desc]}")
            fi
        done

        local cmd=(dialog --backtitle "$__backtitle" --cancel-label "Back" --item-help --help-button --default-item "$default" --menu "Choose an option" 22 76 16)

        local choice
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "${choice}" ]] && break
        if [[ "${choice[@]:0:4}" == "HELP" ]]; then
            choice="${choice[@]:5}"
            default="${choice/%\ */}"
            choice="${choice#* }"
            printMsgs "dialog" "${choice}"
            continue
        fi

        [[ -z "${choice}" ]] && break

        default="${choice}"
        id="${__mod_id[${choice}]}"
        local logfilename
        rps_logInit
        {
            rps_logStart
            if fnExists "gui_${id}"; then
                rp_callModule "${id}" depends
                rp_callModule "${id}" gui
            else
                rp_callModule "${id}" clean
                rp_callModule "${id}"
            fi
            rps_logEnd
        } &> >(_setup_gzip_log "$logfilename")
        rps_printInfo "$logfilename"
    done
}

function update_packages_setup() {
    clear
    local id
    for id in "${__mod_id[@]}"; do
        if rp_isInstalled "${id}" && [[ "${__mod_info[${id}/section]}" != "depends" ]]; then
            rp_installModule "${id}" "_update_"
        fi
    done
}

function check_connection_gui_setup() {
    local ip
    ip="$(getIPAddress)"
    if [[ -z "$ip" ]]; then
        printMsgs "dialog" "Sorry, you don't seem to be connected to the internet, so installing/updating is not available."
        return 1
    fi
    return 0
}

function update_packages_gui_setup() {
    local update="$1"
    if [[ "$update" != "update" ]]; then
        ! check_connection_gui_setup && return 1
        dialog --defaultno --yesno "Are you sure you want to update installed packages?" 22 76 2>&1 >/dev/tty || return 1
        updatescript_setup || return 1
        # Restart at post_update and then call "update_packages_gui_setup update" afterwards
        joy2keyStop
        exec "$scriptdir/archypie_packages.sh" setup post_update update_packages_gui_setup update
    fi

    local update_os=0
    dialog --yesno "Would you like to update OS packages?" 22 76 2>&1 >/dev/tty && update_os=1

    clear

    local logfilename
    rps_logInit
    {
        rps_logStart
        if [[ "$update_os" -eq 1 ]]; then
            pacmanUpdate
        fi
        update_packages_setup
        rps_logEnd
    } &> >(_setup_gzip_log "$logfilename")

    rps_printInfo "$logfilename"
    printMsgs "dialog" "Installed packages have been updated."
    gui_setup
}

function basic_install_setup() {
    local id
    for id in $(rp_getSectionIds core) $(rp_getSectionIds main); do
        rp_installModule "${id}"
    done
    return 0
}

function packages_gui_setup() {
    local section
    local default
    local options=()

    for section in core main opt driver exp depends; do
        options+=("$section" "Manage ${__sections[$section]} Packages" "$section Choose to Install, Update and Configure Packages from the ${__sections[$section]} Section")
    done

    options+=("----" "" "")
    options+=("inst" "Manage All Installed Packages" "Install/Update/Remove Installed Packages")
    options+=("all" "Manage All Packages" "Install/Update/Remove All Available Packages")

    local cmd
    while true; do
        cmd=(dialog --backtitle "$__backtitle" --cancel-label "Back" --item-help --help-button --default-item "$default" --menu "Choose An Option" 22 76 16)

        local choice
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "${choice}" ]] && break
        if [[ "${choice[@]:0:4}" == "HELP" ]]; then
            choice="${choice[@]:5}"
            default="${choice/%\ */}"
            choice="${choice#* }"
            printMsgs "dialog" "${choice}"
            continue
        fi
        [[ "${choice}" != "----" ]] && section_gui_setup "${choice}"
        default="${choice}"
    done
}

function uninstall_setup()
{
    dialog --defaultno --yesno "Are you sure you want to uninstall ArchyPie?" 22 76 2>&1 >/dev/tty || return 0
    dialog --defaultno --yesno "Are you REALLY sure you want to uninstall ArchyPie?\n\n$rootdir will be removed, this includes configuration files for all ArchyPie components." 22 76 2>&1 >/dev/tty || return 0
    clear
    printHeading "Uninstalling ArchyPie"
    for id in "${__mod_id[@]}"; do
        rp_isInstalled "${id}" && rp_callModule "${id}" remove
    done
    rm -rfv "$rootdir"
    dialog --defaultno --yesno "Do you want to remove all the files from $datadir? This includes all your installed ROMs, BIOS files and custom splashscreens." 22 76 2>&1 >/dev/tty && rm -rfv "$datadir"
    if dialog --defaultno --yesno "Do you want to remove all system packages that ArchyPie depends on? \n\nWARNING: This will remove packages like SDL2 even if they were installed before you installed ArchyPie, it will also remove any package configurations, such as those in /etc/samba for Samba.\n\nIf unsure choose No (selected by default)." 22 76 2>&1 >/dev/tty; then
        clear
        # Remove all dependencies.
        for id in "${__mod_id[@]}"; do
            rp_isInstalled "${id}" && rp_callModule "${id}" depends remove
        done
    fi
    printMsgs "dialog" "ArchyPie has been uninstalled."
}

function reboot_setup()
{
    clear
    reboot
}

function gui_setup() {
    joy2keyStart
    depends_setup
    local default
    while true; do
        local commit
        commit=$(sudo -u "${user}" git -C "$scriptdir" log -1 --pretty=format:"%cr (%h)")

        cmd=(dialog --backtitle "$__backtitle" --title "ArchyPie-Setup Script" --cancel-label "Exit" --item-help --help-button --default-item "$default" --menu "Version: $__version - Last Commit: $commit\nSystem: $__platform ($__platform_arch) - Running On: $__os_desc" 22 76 16)
        options=(
            I "Basic Install" "I This will install all packages from Core and Main which gives a basic ArchyPie install. Further packages can then be installed later from the Optional and Experimental sections. If binaries are available they will be used, alternatively packages will be built from source - which will take longer."

            U "Update" "U Updates ArchyPie-Setup and all currently installed packages. Will also allow to update OS packages. If binaries are available they will be used, otherwise packages will be built from source."

            P "Manage Packages"
            "P Install, Remove and Configure the various components of ArchyPie, including emulators, ports, and controller drivers."

            C "Configuration & Tools"
            "C Configuration & Tools. Any packages you have installed that have additional configuration options will also appear here."

            S "Update ArchyPie-Setup Script"
            "S Update the ArchyPie-Setup script. This will update the main management script only, but will not update any software packages. To update packages use the 'Update' option from the main menu, which will also update the ArchyPie-Setup script."

            X "Uninstall ArchyPie"
            "X Uninstall ArchyPie completely."

            R "Perform Reboot"
            "R Reboot your machine."
        )

        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "${choice}" ]] && break

        if [[ "${choice[@]:0:4}" == "HELP" ]]; then
            choice="${choice[@]:5}"
            default="${choice/%\ */}"
            choice="${choice#* }"
            printMsgs "dialog" "${choice}"
            continue
        fi
        default="${choice}"

        case "${choice}" in
            I)
                ! check_connection_gui_setup && continue
                dialog --defaultno --yesno "Are you sure you want to do a basic install?\n\nThis will install all packages from the 'Core' and 'Main' package sections." 22 76 2>&1 >/dev/tty || continue
                clear
                local logfilename
                rps_logInit
                {
                    rps_logStart
                    basic_install_setup
                    rps_logEnd
                } &> >(_setup_gzip_log "$logfilename")
                rps_printInfo "$logfilename"
                ;;
            U)
                update_packages_gui_setup
                ;;
            P)
                packages_gui_setup
                ;;
            C)
                config_gui_setup
                ;;
            S)
                ! check_connection_gui_setup && continue
                dialog --defaultno --yesno "Are you sure you want to update the ArchyPie-Setup script?" 22 76 2>&1 >/dev/tty || continue
                if updatescript_setup; then
                    joy2keyStop
                    exec "$scriptdir/archypie_packages.sh" setup post_update gui_setup
                fi
                ;;
            X)
                local logfilename
                rps_logInit
                {
                    uninstall_setup
                } &> >(_setup_gzip_log "$logfilename")
                rps_printInfo "$logfilename"
                ;;
            R)
                dialog --defaultno --yesno "Are you sure you want to reboot?\n\nNote that if you reboot when EmulationStation is running, you will lose any metadata changes." 22 76 2>&1 >/dev/tty || continue
                reboot_setup
                ;;
        esac
    done
    joy2keyStop
    clear
}
