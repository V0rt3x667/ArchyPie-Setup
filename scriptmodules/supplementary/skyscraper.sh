#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="skyscraper"
rp_module_desc="Scraper For EmulationStation By Lars Muldjord (Detain Fork)"
rp_module_licence="GPL3 https://raw.githubusercontent.com/detain/skyscraper/master/LICENSE"
rp_module_repo="git https://github.com/detain/skyscraper :_get_branch_skyscraper"
rp_module_section="opt"

function _get_branch_skyscraper() {
    download "https://api.github.com/repos/detain/skyscraper/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_skyscraper() {
    local depends=(
        'nano'
        'qt5-base'
        'p7zip'
    )
    getDepends "${depends[@]}"
}

function sources_skyscraper() {
    gitPullOrClone

    # Replace References To RetroPie/retropie
    local files=(
        'src/attractmode.cpp'
        'src/emulationstation.cpp'
        'src/main.cpp'
        'src/nametools.cpp'
        'src/pegasus.cpp'
        'src/skyscraper.cpp'
    )
    for file in "${files[@]}"; do
        sed -e 's|RetroPie|ArchyPie|g' -i "${md_build}/${file}"
        sed -e 's|retropie|archypie|g' -i "${md_build}/${file}"
    done
}

function build_skyscraper() {
    QT_SELECT=5 qmake
    make
    md_ret_require="${md_build}/Skyscraper"
}

function install_skyscraper() {
    md_ret_files=(
        'aliasMap.csv'
        'artwork.xml.example1'
        'artwork.xml.example2'
        'artwork.xml.example3'
        'artwork.xml.example4'
        'artwork.xml'
        'cache/priorities.xml.example'
        'config.ini.example'
        'hints.txt'
        'import'
        'LICENSE'
        'mameMap.csv'
        'README.md'
        'resources'
        'Skyscraper'
        'tgdb_developers.json'
        'tgdb_publishers.json'
    )
}

# Get The Location Of The Cached Resources Folder
function _cache_folder_skyscraper() {
    if [[ -d "${configdir}/all/skyscraper/dbs" ]]; then
        echo "dbs"
    else
        echo "cache"
    fi
}

# Purge All Skyscraper Caches
function _purge_skyscraper() {
    local platform
    local cache_folder

    cache_folder=$(_cache_folder_skyscraper)

    [[ ! -d "${configdir}/all/skyscraper/${cache_folder}" ]] && return

    while read platform; do
        # Find Any Sub-Folders Of The Cache Folder And Clear Them
        _clear_platform_skyscraper "${platform}"
    done < <(find "${configdir}/all/skyscraper/${cache_folder}" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;)
}

function _clear_platform_skyscraper() {
    local platform="$1"
    local mode="$2"
    local cache_folder
    
    cache_folder=$(_cache_folder_skyscraper)

    [[ ! -d "${configdir}/all/skyscraper/${cache_folder}/${platform}" ]] && return

    if [[ ${mode} == "vacuum" ]]; then
        sudo -u "${user}" stdbuf -o0 "${md_inst}/Skyscraper" --flags unattend -p "${platform}" --cache vacuum
    else
        sudo -u "${user}" stdbuf -o0 "${md_inst}/Skyscraper" --flags unattend -p "${platform}" --cache purge:all
    fi
    sleep 5
}

function _purge_platform_skyscraper() {
    local options=()
    local cache_folder
    local system

    cache_folder=$(_cache_folder_skyscraper)

    while read system; do
        # If There Is No 'db.xml' File Underneath The Folder, Skip It, It Means Folder Is Empty
        [[ ! -f "${configdir}/all/skyscraper/${cache_folder}/${system}/db.xml" ]] && continue

        # Get The Size On Disk Of The System And Show It In The Select List
        local size
        size=$(du -sh  "${configdir}/all/skyscraper/${cache_folder}/${system}" | cut -f1)
        options+=("${system}" "${size}" OFF)
    done < <(find "${configdir}/all/skyscraper/${cache_folder}" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;)

    # If No Folders Are Found, Show An Info Message Instead Of The Selection List
    if [[ ${#options[@]} -eq 0 ]] ; then
        printMsgs "dialog" "Nothing To Delete! No Cached Platforms Found In: \n${configdir}/all/skyscraper/${cache_folder}"
        return
    fi

    local mode="$1"
    [[ -z "${mode}" ]] && mode="purge"

    local cmd=(dialog --backtitle "${__backtitle}" --radiolist "Select Platform To ${mode}" 20 60 12)
    local platform

    platform=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    # Exit If No Platform Chosen
    [[ -z "${platform}" ]] && return

    _clear_platform_skyscraper "${platform}" "$@"
}

function _get_ver_skyscraper() {
    if [[ -f "${md_inst}/Skyscraper" ]]; then
        echo $("${md_inst}/Skyscraper" -h | grep 'Running Skyscraper' | cut -d' '  -f 3 | tr -d v 2>/dev/null)
    fi
}

function _check_ver_skyscraper() {
    ver=$(_get_ver_skyscraper)

    compareVersions "${ver}" "3.5"

    if [[ $? == -1 ]]; then
        printMsgs "dialog" "The Version Of Skyscraper You Currently Have Installed Is Incompatible With Options Used By This Script. Please Update Skyscraper To The Latest Version To Continue."
        return 1
    fi
    return 0
}

# List Any Non-Empty Systems Found In The ROM Folder
function _list_systems_skyscraper() {
    find -L "${romdir}/" -mindepth 1 -maxdepth 1 -type d -not -empty | sort -u
}

function remove_skyscraper() {
    # On Removal Of The Package Purge The Cache
    _purge_skyscraper
}

function configure_skyscraper() {
    if [[ "${md_mode}" == "remove" ]]; then
        return
    fi

    # Check If This A First Time Install
    local local_config
    local_config=$(readlink -qn "${home}/.skyscraper")

    # Handle Cases Where The User Has An Existing Skyscraper Installation
    if [[ -d "${home}/.skyscraper" && "${local_config}" != "${configdir}/all/skyscraper" ]]; then
        # Since The ${HOME}/.skyscraper Folder Will Be Moved, Make Sure The 'cache' &'import' Folders Are Moved Separately
        local f_size
        local cache_folder="dbs"
        [[ -d "${home}/.skyscraper/cache" ]] && cache_folder="cache"

        f_size=$(du --total -sm "${home}/.skyscraper/${cache_folder}" "${home}/.skyscraper/import" 2>/dev/null | tail -n 1 | cut -f 1 )
        printMsgs "console" "INFO: Moving The Cache And Import Folders To New Configuration Folder (Total: ${f_size} Mb)"

        local folder
        for folder in ${cache_folder} import; do
            mv "${home}/.skyscraper/${folder}" "${home}/.skyscraper-${folder}" && \
                printMsgs "console" "INFO: Moved ${home}/.skyscraper/${folder} To ${home}/.skyscraper-${folder}"
        done

        # Create A GUI Config
        iniConfig " = " '"' "${configdir}/all/skyscraper.cfg"
        iniSet "use_rom_folder" 1
    fi

    moveConfigDir "${home}/.skyscraper" "${configdir}/all/skyscraper"

    # Move Cache And Import Folders Back To The New Conf Folder
    for folder in ${cache_folder} import; do
        if [[ -d "${home}/.skyscraper-${folder}" ]]; then
            printMsgs "console" "INFO: Moving ${home}/.skyscraper-${folder} Back To The Configuration Folder"
            mv  "${home}/.skyscraper-${folder}" "${configdir}/all/skyscraper/${folder}"
        fi
    done

    _init_config_skyscraper
    chown -R "${user}:${user}" "${configdir}/all/skyscraper"
}

function _init_config_skyscraper() {
    local scraper_conf_dir="${configdir}/all/skyscraper"

    # Make Sure The `artwork.xml` And Other Conf Files Are Present
    local f_conf
    for f_conf in artwork.xml aliasMap.csv; do
        if [[ -f "${scraper_conf_dir}/${f_conf}" ]]; then
            cp -f "${md_inst}/${f_conf}" "${scraper_conf_dir}/${f_conf}.default"
        else
            cp "${md_inst}/${f_conf}" "${scraper_conf_dir}"
        fi
    done

    # If We Don't Have A Previous 'config.ini' File Copy The Example One
    if [[ ! -f "${scraper_conf_dir}/config.ini" ]]; then
        cp "${md_inst}/config.ini.example" "${scraper_conf_dir}/config.ini"
        sed -i 's|\[esgamelist\]|\[esgamelist\]\ncacheScreenshots="false"|' "${scraper_conf_dir}/config.ini"
    fi

    # Try To Find The Rest Of The Necessary Files From The Qmake Build File
    # They Should Be Listed In The `unix:examples.file` Configuration Line
    if [[ $(grep unix:examples.files "${md_build}/skyscraper.pro" 2>/dev/null | cut -d= -f2-) ]]; then
        local files
        local file

        files=$(grep unix:examples.files "${md_build}/skyscraper.pro" | cut -d= -f2-)

        for file in ${files}; do
            # Copy The Files To The Configuration Folder Except 'config.ini', 'artwork.xml' & 'aliasMap.csv'
            if [[ ${file} != "artwork.xml" && ${file} != "config.ini" && ${file} != "aliasMap.csv" ]]; then
                cp -f "${md_build}/${file}" "${scraper_conf_dir}"
            fi
        done
    else
        # Fallback To The Known Resource Files List
        cp -f "${md_inst}/artwork.xml.example"* "${scraper_conf_dir}"

        # Copy Resources & Readme
        local resource_file
        for resource_file in hints.txt mameMap.csv README.md tgdb_developers.json tgdb_publishers.json; do
            cp -f "${md_inst}/${resource_file}" "${scraper_conf_dir}"
        done
    fi

    # Copy The Rest Of The Folders
    cp -rf "${md_inst}/resources" "${scraper_conf_dir}"

    # Create The Import Folders & Add The Sample Files
    local folder
    for folder in covers marquees screenshots textual videos wheels; do
        mkUserDir "${scraper_conf_dir}/import/${folder}"
    done
    cp -rf "${md_inst}/import" "${scraper_conf_dir}"

    # Create The Cache Folder & Add The Sample 'priorities.xml' File
    mkdir -p "${scraper_conf_dir}/cache"
    cp -f "${md_inst}/priorities.xml.example" "${scraper_conf_dir}/cache"
}

# Scrape One System, Passed As Parameter
function _scrape_skyscraper() {
    local system="$1"

    [[ -z "${system}" ]] && return

    iniConfig " = " '"' "${configdir}/all/skyscraper.cfg"
    eval "$(_load_config_skyscraper)"

    local -a params=(-p "${system}")
    local flags="unattend,skipped,"

    [[ "${download_videos}" -eq 1 ]] && flags+="videos,"

    [[ "${cache_marquees}" -eq 0 ]] && flags+="nomarquees,"

    [[ "${cache_covers}" -eq 0 ]] && flags+="nocovers,"

    [[ "${cache_screenshots}" -eq 0 ]] && flags+="noscreenshots,"

    [[ "${cache_wheels}" -eq 0 ]] && flags+="nowheels,"

    [[ "${only_missing}" -eq 1 ]] && flags+="onlymissing,"

    [[ "${rom_name}" -eq 1 ]] && flags+="forcefilename,"

    [[ "${remove_brackets}" -eq 1 ]] && flags+="nobrackets,"

    if [[ "${use_rom_folder}" -eq 1 ]]; then
        params+=(-g "${romdir}/${system}")
        params+=(-o "${romdir}/${system}/media")
        # Use Relative Paths In The Gamelist
        flags+="relative,"
    else
        params+=(-g "${home}/.emulationstation/gamelists/${system}")
        params+=(-o "${home}/.emulationstation/downloaded_media/${system}")
    fi

    # If 2nd Parameter Is Unset, Use The Configured Scraping Source, Otherwise Scrape From Cache
    # Scraping From Cache Means We Can Omit '-s' From The Parameter List
    if [[ -z "$2" ]]; then
        params+=(-s "${scrape_source}")
    fi

    [[ "${force_refresh}" -eq 1 ]] && params+=(--refresh)

    # There Will Always Be ',' At The End Of ${flags}, Remove It
    flags=${flags::-1}

    params+=(--flags "${flags}")

    # Trap 'ctrl+c' & Return If Pressed Rather Than Exiting ArchyPie-Setup
    trap 'trap 2; return 1' INT
        sudo -u "${user}" stdbuf -o0  "${md_inst}/Skyscraper" "${params[@]}"
        echo -e "\nCOMMAND LINE USED:\n ${md_inst}/Skyscraper" "${params[@]}"
        sleep 2
    trap 2
}

# Scrape A List Of Systems Chosen By The User
function _scrape_chosen_skyscraper() {
    ! _check_ver_skyscraper && return 1

    local options=()
    local system
    local i=1

    while read system; do
        system=${system/${romdir}\//}
        options+=($i "${system}" OFF)
        ((i++))
    done < <(_list_systems_skyscraper)

    if [[ ${#options[@]} -eq 0 ]] ; then
        printMsgs "dialog" "No Populated ROM Folders Were Found In: ${romdir}"
        return
    fi

    local choices
    local cmd=(dialog --backtitle "$__backtitle" --ok-label "Start" --cancel-label "Back" --checklist " Select Platforms For Resource Gathering\n\n" 22 60 16)

    choices=($("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty))

    # Exit If Nothing Was Chosen Or Cancel Was Used
    [[ ${#choices[@]} -eq 0 || $? -eq 1 ]] && return 1

    # Confirm With The User That Scraping Can Start
    dialog --clear --colors --yes-label "Proceed" --no-label "Abort" --yesno "This Will Start The Gathering Process, Which Can Take A Long Time If You Have A Large Game Collection.\n\nYou Can Interrupt This Process Anytime By Pressing \ZbCtrl+C\Zn.\nProceed?" 12 70 2>&1 >/dev/tty
    [[ ! $? -eq 0 ]] && return 1

    local choice

    for choice in "${choices[@]}"; do
        choice="${options[choice*3-2]}"
        _scrape_skyscraper "${choice}" "$@"
    done
}

# Generate Gamelists For A List Of Systems Chosen By The User
function _generate_chosen_skyscraper() {
    ! _check_ver_skyscraper && return 1

    local options=()
    local system
    local i=1

    while read system; do
        system=${system/${romdir}\//}
        options+=($i "${system}" OFF)
        ((i++))
    done < <(_list_systems_skyscraper)

    if [[ ${#options[@]} -eq 0 ]] ; then
        printMsgs "dialog" "No Populated ROM Folders Were Found In: ${romdir}"
        return
    fi

    local choices
    local cmd=(dialog --backtitle "$__backtitle" --ok-label "Start" --cancel-label "Back" --checklist " Select Platforms For Gamelist(s) Generation\n\n" 22 60 16)

    choices=($("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty))

    # Exit If Nothing Was Chosen Or Cancel Was Used
    [[ ${#choices[@]} -eq 0 || $? -eq 1 ]] && return 1

    for choice in "${choices[@]}"; do
        choice="${options[choice*3-2]}"
        _scrape_skyscraper "${choice}" "cache" "$@"
    done
}

function _load_config_skyscraper() {
    echo "$(loadModuleConfig \
        'rom_name=0' \
        'use_rom_folder=0' \
        'download_videos=0' \
        'cache_marquees=1' \
        'cache_covers=1' \
        'cache_wheels=1' \
        'cache_screenshots=1' \
        'scrape_source=screenscraper' \
        'remove_brackets=0' \
        'force_refresh=0' \
        'only_missing=0'
    )"
}

function _open_editor_skyscraper() {
  local editor
  editor="${EDITOR:-nano}"
  sudo -u "${user}" "${editor}" "$1" >/dev/tty </dev/tty
}

function _gui_advanced_skyscraper() {
    declare -A help_strings_adv

    iniConfig " = " '"' "${configdir}/all/skyscraper.cfg"
    eval "$(_load_config_skyscraper)"

    help_strings_adv=(
        [E]="Opens The Configuration File \Zbconfig.ini\Zn In An Editor."
        [F]="Opens The Artwork Definition File \Zbartwork.xml\Zn In An Editor."
        [G]="Opens The Game Alias Configuration File \ZbaliasMap.csv\Zn In An Editor."
    )

    while true; do
        local cmd=(dialog --backtitle "${__backtitle}" --help-button --colors --no-collapse --default-item "${default}" --ok-label "Ok" --cancel-label "Back" --title "Advanced Options" --menu "    EXPERT - Edit Configurations\n" 14 50 5)
        local options=()

        options+=(E "Edit 'config.ini'")
        options+=(F "Edit 'artwork.xml'")
        options+=(G "Edit 'aliasMap.csv'")

        local choice
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 > /dev/tty)

        if [[ -n "${choice}" ]]; then
            local default="${choice}"

            case "${choice}" in

                E)
                    _open_editor_skyscraper "${configdir}/all/skyscraper/config.ini"
                    ;;

                F)
                    _open_editor_skyscraper "${configdir}/all/skyscraper/artwork.xml"
                    ;;

                G)
                    _open_editor_skyscraper "${configdir}/all/skyscraper/aliasMap.csv"
                    ;;

                HELP*)
                    # Retain Choice
                    default="${choice/HELP /}"
                    if [[ -n "${help_strings_adv[${default}]}" ]]; then
                    dialog --colors --no-collapse --ok-label "Close" --msgbox "${help_strings_adv[${default}]}" 22 65 >&1
                    fi
            esac
        else
            break
        fi
    done
}

function gui_skyscraper() {
    if pgrep "emulationstatio" >/dev/null; then
        printMsgs "dialog" "This Scraper Must Not Be Run While EmulationStation Is Running Or The Scraped Data Will Be Overwritten!\n\nPlease Quit EmulationStation And Run ArchyPie-Setup From The Terminal."
        return
    fi

    iniConfig " = " '"' "${configdir}/all/skyscraper.cfg"
    eval "$(_load_config_skyscraper)"
    chown "${user}":"${user}" "${configdir}/all/skyscraper.cfg"

    local -a s_source
    local -a s_source_names
    declare -A help_strings

    s_source=(
        [1]=screenscraper
        [2]=arcadedb
        [3]=thegamesdb
        [4]=openretro
        [5]=worldofspectrum
    )
    s_source+=(
        [10]=esgamelist
        [11]=import
    )

    s_source_names=(
        [1]=ScreenScraper
        [2]=ArcadeDB
        [3]=TheGamesDB
        [4]=OpenRetro
        [5]="World of Spectrum"
    )
    s_source_names+=(
        [10]="EmulationStation Gamelist"
        [11]="Import Folder"
    )

    local ver

    help_strings=(
        [1]="Gather Resources And Cache Them For The Platforms Found In: \Zb${romdir}\Zn.\nRuns The Scraper To Download The Information And Media From The Selected Gathering Source."
        [2]="Select The Source For ROM Scraping. Supported Sources:\n\ZbONLINE\Zn\n * ScreenScraper (screenscraper.fr)\n * TheGamesDB (thegamesdb.net)\n * OpenRetro (openretro.org)\n * ArcadeDB (adb.arcadeitalia.net)\n * World of Spectrum (worldofspectrum.org)\n\ZbLOCAL\Zn\n * EmulationStation Gamelist (Imports Data From ES Gamelist)\n * Import (Imports Resources In The Local Cache)\n\n\Zb\ZrNOTE\Zn: Some Sources Require A Username And Password For Access. These Can Be Set Per Source In The \Zbconfig.ini\Zn Configuration File.\n\n Skyscraper Parameter: \Zb-s <source_name>\Zn"
        [3]="Options For Resource Gathering And Caching Sub-Menu.\nClick To Open It."
        [4]="Generate EmulationStation Game Lists.\nRuns The Scraper To Incorporate Downloaded Information And Media From The Local Cache And Write Them To \Zbgamelist.xml\Zn Files To Be Used By EmulationStation."
        [5]="Options For EmulationStation Game List Generation Sub-Menu.\nClick to open it and change the options."
        [V]="Toggle The Download And Caching Of Videos.\nThis Also Toggles Whether The Videos Will Be Included In The Resulting Gamelist.\n\nSkyscraper Option: \Zb--flags videos\Zn"
        [A]="Advanced Options Sub-Menu."
        [U]="Check For An Update To Skyscraper."
    )

    ver=$(_get_ver_skyscraper)

    while true; do
        [[ -z "${ver}" ]] && ver="v(Git)"

        local cmd=(dialog --backtitle "$__backtitle" --colors --cancel-label "Exit" --help-button --no-collapse --cr-wrap --default-item "${default}" --menu "   Skyscraper: Game Scraper By Lars Muldjord (${ver})\\n \\n" 22 60 12)

        local options=(
            "-" "GATHER & Cache Resources"
        )

        local source_found=0
        local online="Online"
        local i

        options+=(
            1 "Gather Resources"
        )

        for i in "${!s_source[@]}"; do
            if [[ "${scrape_source}" == "${s_source[$i]}" ]]; then
                [[ $i -ge 10 ]] && online="Local"
                options+=(2 "Gather Source - ${s_source_names[$i]} (${online}) -->")
                source_found=1
            fi
        done

        if [[ ${source_found} -ne 1 ]]; then
            options+=(2 "Gather From - Screenscraper (Online) -->")
            scrape_source="screenscraper"
            iniSet "scrape_source" "${scrape_source}"
        fi

        options+=(3 "Cache Options & Commands -->")

        options+=("-" "GAME LIST Generation")
        options+=(4 "Generate Game List(s)")
        options+=(5 "Generate Options -->")

        options+=("-" "OTHER Options")

        if [[ "${download_videos}" -eq 1 ]]; then
            options+=(V "Download Videos (Enabled)")
        else
            options+=(V "Download Videos (Disabled)")
        fi

        options+=(A "Advanced Options -->")

        options+=(U "Check For Updates")

        # Run The GUI
        local choice

        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

        if [[ -n "${choice}" ]]; then
            local default="${choice}"

            case "${choice}" in
                1)
                    if _scrape_chosen_skyscraper; then
                        printMsgs "dialog" "ROM Information Gathered.\n\nDon't Forget To Use 'Generate Game List(s)' To Add This Information To EmulationStation."
                    elif [[ $? -eq 2 ]]; then
                        printMsgs "dialog" "Gathering Was Aborted"
                    fi
                    ;;
                2)
                    # Scrape Source Options Have A Separate Dialog
                    local s_options=()
                    local i

                    for i in "${!s_source[@]}"; do
                        online="Online:"
                        [[ i -ge 10 ]] && online="Local:"

                        if [[ "${scrape_source}" == "${s_source[$i]}" ]]; then
                            s_default="${online} ${s_source_names[$i]}"
                        fi

                        s_options+=("${online} ${s_source_names[$i]}" "")
                    done

                    if [[ -z "${s_default}" ]]; then
                        s_default="Online: ${s_source_names[1]}"
                    fi

                    local s_cmd=(dialog --title "Select Scraping Source" --default-item "${s_default}" \
                        --menu "Choose One Of The Available Scraping Sources" 18 50 9)

                    # Run The Scraper Source Selection Dialog
                    local scrape_source_name

                    scrape_source_name=$("${s_cmd[@]}" "${s_options[@]}" 2>&1 >/dev/tty)

                    # If Cancel Was Chosen Don't Do Anything
                    [[ -z "${scrape_source_name}" ]] && continue

                    # Strip The "XYZ:" Prefix From The Chosen Scraper Source, Then Compare To Our List
                    local src

                    src=$(echo "${scrape_source_name}" | cut -d' ' -f2-)

                    for i in "${!s_source_names[@]}"; do
                        [[ "${s_source_names[$i]}" == "${src}" ]] && scrape_source=${s_source[$i]}
                    done

                    iniSet "scrape_source" "${scrape_source}"
                    ;;
                3)
                    _gui_cache_skyscraper
                    ;;
                4)
                    if _generate_chosen_skyscraper "cache"; then
                        printMsgs "dialog" "Game List(s) Generated."
                    elif [[ $? -eq 2 ]]; then
                        printMsgs "dialog" "Game List Generation Aborted"
                    fi
                    ;;
                5)
                    _gui_generate_skyscraper
                    ;;
                V)
                    download_videos="$((download_videos ^ 1))"
                    iniSet "download_videos" "${download_videos}"
                    ;;
                A)
                    _gui_advanced_skyscraper
                    ;;
                U)
                    local latest_ver
                    latest_ver="$(_get_branch_skyscraper)"
                    # Check For Update
                    compareVersions "${latest_ver}" "${ver}"
                    if [[ $? == -1 ]]; then
                        printMsgs "dialog" "There Is A New Version Available. Latest Released Version Is ${latest_ver} (You Are Running ${ver}).\n\nYou Can Update The Package From ArchyPie-Setup -> Manage Packages"
                    else
                        printMsgs "dialog" "You Are Running The Latest Version (${ver})"
                    fi
                    ;;

                HELP*)
                    # Retain Choice When The Help Button Is Selected
                    default="${choice/HELP /}"
                    if [[ ! -z "${help_strings[${default}]}" ]]; then
                        dialog --colors --no-collapse --ok-label "Close" --msgbox "${help_strings[${default}]}" 22 65 >&1
                    fi
                    ;;
            esac
        else
            break
        fi
    done
}

function _gui_cache_skyscraper() {
    local db_size
    local cache_folder=$(_cache_folder_skyscraper)
    declare -A help_strings_cache

    iniConfig " = " '"' "${configdir}/all/skyscraper.cfg"
    eval "$(_load_config_skyscraper)"

    help_strings_cache=(
        [1]="Toggle Whether Screenshots Are Cached Locally When Scraping.\n\nSkyscraper Option: \Zb--flags noscreenshots\Zn"
        [2]="Toggle Whether Covers Are Cached Locally When Scraping.\n\nSkyscraper Option: \Zb--flags nocovers\Zn"
        [3]="Toggle Whether Wheels Are Cached Locally When Scraping.\n\nSkyscraper Option: \Zb--flags nowheels\Zn"
        [4]="Toggle Whether Marquees Are Cached Locally When Scraping.\n\nSkyscraper Option: \Zb--flags nomarquees\Zn"
        [5]="Enable This To Only Scrape Files That Do Not Already Have Data In The Skyscraper Resource Cache.\n\nSkyscraper Option: \Zb--flags onlymissing\Zn"
        [6]="Force The Refresh Of Resources In The Local Cache When Scraping.\n\nSkyscraper Option: \Zb--cache refresh\Zn"
        [P]="Purge \ZbALL\Zn All Cached Resources For All Platforms."
        [S]="Purge All Cached Resources For A Chosen Platform.\n\nSkyscraper Option: \Zb--cache purge:all\Zn"
        [V]="Removes All Non-Used Cached Resources For A Chosen Platform (vacuum).\n\nSkyscraper Option: \Zb--cache vacuum\Zn"
    )

    while true; do
        db_size=$(du -sh "${configdir}/all/skyscraper/${cache_folder}" 2>/dev/null | cut -f 1 || echo 0m)
        [[ -z "${db_size}" ]] && db_size="0Mb"

        local cmd=(dialog --backtitle "${__backtitle}" --help-button --colors --no-collapse --default-item "${default}" --ok-label "Ok" --cancel-label "Back" --title "Cache Options & Commands" --menu "\n               Current Cache Size: ${db_size}\n\n" 21 60 12)

        local options=("-" "OPTIONS For Gathering & Caching")

        if [[ "${cache_screenshots}" -eq 1 ]]; then
            options+=(1 "Cache Screenshots (Enabled)")
        else
            options+=(1 "Cache Screenshots (Disabled)")
        fi

        if [[ "${cache_covers}" -eq 1 ]]; then
            options+=(2 "Cache Covers (Enabled)")
        else
            options+=(2 "Cache Covers (Disabled)")
        fi

        if [[ "${cache_wheels}" -eq 1 ]]; then
            options+=(3 "Cache Wheels (Enabled)")
        else
            options+=(3 "Cache Wheels (Disabled)")
        fi

        if [[ "${cache_marquees}" -eq 1 ]]; then
            options+=(4 "Cache Marquees (Enabled)")
        else
            options+=(4 "Cache Marquees (Disabled)")
        fi

        if [[ "${only_missing}" -eq 1 ]]; then
            options+=(5 "Scrape Only Missing (Enabled)")
        else
            options+=(5 "Scrape Only Missing (Disabled)")
        fi

        if [[ "${force_refresh}" -eq 0 ]]; then
            options+=(6 "Force Cache Refresh (Disabled)")
        else
            options+=(6 "Force Cache Refresh (Enabled)")
        fi

        options+=("-" "PURGE Cache Commands")
        options+=(V "Vacuum Chosen Platform")
        options+=(S "Purge Chosen Platform")
        options+=(P "Purge All Platforms(!)")

        local choice

        choice=$("${cmd[@]}" "${options[@]}" 2>&1 > /dev/tty)

        if [[ -n "${choice}" ]]; then
            local default="${choice}"

            case "${choice}" in
                1)
                    cache_screenshots="$((cache_screenshots ^ 1))"
                    iniSet "cache_screenshots" "${cache_screenshots}"
                    ;;
                2)
                    cache_covers="$((cache_covers ^ 1))"
                    iniSet "cache_covers" "${cache_covers}"
                    ;;
                3)
                    cache_wheels="$((cache_wheels ^ 1))"
                    iniSet "cache_wheels" "${cache_wheels}"
                    ;;
                4)
                    cache_marquees="$((cache_marquees ^ 1))"
                    iniSet "cache_marquees" "${cache_marquees}"
                    ;;
                5)
                    only_missing="$((only_missing ^ 1))"
                    iniSet "only_missing" "${only_missing}"
                    ;;
                6)
                    force_refresh="$((force_refresh ^ 1))"
                    iniSet "force_refresh" "${force_refresh}"
                    ;;
                V)
                    _purge_platform_skyscraper "vacuum"
                    ;;
                S)
                    _purge_platform_skyscraper
                    ;;
                P)
                    dialog --clear --defaultno --colors --yesno  "\Z1\ZbAre You Sure?\Zn\nThis Will \Zb\ZuERASE\Zn All Locally Cached Scraped Resources" 8 60 2>&1 >/dev/tty
                    if [[ $? == 0 ]]; then
                        _purge_skyscraper
                    fi
                    ;;
                HELP*)
                    # Retain Choice
                    default="${choice/HELP /}"
                    if [[ -n "${help_strings_cache[${default}]}" ]]; then
                    dialog --colors --no-collapse --ok-label "Close" --msgbox "${help_strings_cache[${default}]}" 22 65 >&1
                    fi
            esac
        else
            break
        fi
    done
}

function _gui_generate_skyscraper() {
    declare -A help_strings_gen

    iniConfig " = " '"' "${configdir}/all/skyscraper.cfg"
    eval "$(_load_config_skyscraper)"

    help_strings_gen=(
        [1]="Game Name Format Used In The Emulationstation Game List. Available Options:\n\n\ZbSource Name\Zn: Use The Name Returned By The Scraper\n\ZbFilename\Zn: Use The Filename Of The ROM As Game Name\n\nSkyscraper Option: \Zb--flags forcefilename\Z0"
        [2]="Game Name Option To Remove Or Keep The Text Found Between '()' And '[]' In The ROMs Filename.\n\nSkyscraper Option: \Zb--flags nobrackets\Zn"
        [3]="Choose To Save The Generated 'gamelist.xml' And Media In The ROMs Folder. Supported Options:\n\n\ZbEnabled\Zn Saves The 'gamelist.xml' In The ROMs Folder And The Media In The 'media' Sub-Folder.\n\n\ZbDisabled\Zn Saves The 'gamelist.xml' In: \Zu\${HOME}/.emulationstation/gamelists/<system>\Zn And The Media In \Zu\${HOME}/.emulationstation/downloaded_media\Zn.\n\n\Zb\ZrNOTE\Zn: Changing This Option Will Not Automatically Copy The 'gamelist.xml' File And The Media To The New Location Or Remove The Ones In The Old Location. You Must Do This Manually.\n\nSkyscraper Parameters: \Zb-g <gamelist>\Zn / \Zb-o <path>\Zn"
    )

    while true; do
        local cmd=(dialog --backtitle "${__backtitle}" --help-button --colors --no-collapse --default-item "${default}" --ok-label "Ok" --cancel-label "Back" --title "Game List Generation Options" --menu "\n\n" 13 60 5)
        local -a options

        if [[ "${rom_name}" -eq 0 ]]; then
            options=(1 "ROM Names (Source Name)")
        else
            options=(1 "ROM Names (Filename)")
        fi

        if [[ "${remove_brackets}" -eq 1 ]]; then
            options+=(2 "Remove Bracket Info (Enabled)")
        else
            options+=(2 "Remove Bracket Info (Disabled)")
        fi

        if [[ "${use_rom_folder}" -eq 1 ]]; then
            options+=(3 "Use ROM Folders For Game List & Media (Enabled)")
        else
            options+=(3 "Use ROM Folders For Game List & Media (Disabled)")
        fi

        local choice
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 > /dev/tty)

        if [[ -n "${choice}" ]]; then
            local default="${choice}"

            case "${choice}" in
                1)
                    rom_name="$((rom_name ^ 1))"
                    iniSet "rom_name" "${rom_name}"
                    ;;
                2)
                    remove_brackets="$((remove_brackets ^ 1))"
                    iniSet "remove_brackets" "${remove_brackets}"
                    ;;
                3)
                    use_rom_folder="$((use_rom_folder ^ 1))"
                    iniSet "use_rom_folder" "${use_rom_folder}"
                    ;;
                HELP*)
                    # Retain Choice
                    default="${choice/HELP /}"
                    if [[ -n "${help_strings_gen[${default}]}" ]]; then
                    dialog --colors --no-collapse --ok-label "Close" --msgbox "${help_strings_gen[${default}]}" 22 65 >&1
                    fi
            esac
        else
            break
        fi
    done
}
