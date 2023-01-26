#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="solarus"
rp_module_desc="Solarus: Action-RPG/Adventure 2D Game Engine"
rp_module_help="Copy Solarus Games (.solarus) to: ${romdir}/solarus"
rp_module_licence="GPL3 https://gitlab.com/solarus-games/solarus/raw/dev/license.txt"
rp_module_repo="git https://gitlab.com/solarus-games/solarus master"
rp_module_section="opt"
rp_module_flags=""

function _options_cfg_file_solarus() {
    echo "${configdir}/${md_id}/options.cfg"
}

function depends_solarus() {
    local depends=(
        'cmake'
        'glm'
        'libmodplug'
        'libpng'
        'libvorbis'
        'luajit'
        'ninja'
        'openal'
        'physfs'
        'sdl2_image'
        'sdl2_ttf'
        'sdl2'
    )
    getDepends "${depends[@]}"
}

function sources_solarus() {
    gitPullOrClone
}

function build_solarus() {
    local params
    isPlatform "gles" && params+=('-DSOLARUS_GL_ES=ON')

    cmake . \
        -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="${md_inst}" \
        -DCMAKE_BUILD_RPATH_USE_ORIGIN="ON" \
        -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS} -Wl,-rpath='${md_inst}/lib'" \
        -DSOLARUS_GUI="OFF" \
        -DSOLARUS_TESTS="OFF" \
        -DSOLARUS_FILE_LOGGING="OFF" \
        -DSOLARUS_LIBRARY_INSTALL_DESTINATION="${md_inst}/lib" \
        -DSOLARUS_BASE_WRITE_DIR="${configdir}" \
        -DSOLARUS_WRITE_DIR="${md_id}" \
        "${params[@]}" \
        -Wno-dev
    ninja -C build clean
    ninja -C build
    md_ret_require=("${md_build}/build/${md_id}-run")
}

function install_solarus() {
    ninja -C build install/strip
}

function configure_solarus() {
    if [[ "${md_mode}" == "install" ]]; then
        mkRomDir "${md_id}"

        # Create A Launcher For Solarus That:
        #  1) Starts In Fullscreen Mode
        #  2) Disables The Mouse Cursor, JACK Driver In OpenAL And The Lua Console
        #  3) Configures The Joypad Deadzone And Quit Combo Options
        cat > "${md_inst}/${md_id}.sh" << _EOF_
#!/usr/bin/env bash
export ALSOFT_DRIVERS="-jack,"
ARGS=("-fullscreen=yes" "-cursor-visible=no" "-lua-console=no")
[[ -f "$(_options_cfg_file_solarus)" ]] && source "$(_options_cfg_file_solarus)"
[[ -n "\$JOYPAD_DEADZONE" ]] && ARGS+=("-joypad-deadzone=\$JOYPAD_DEADZONE")
[[ -n "\$QUIT_COMBO" ]] && ARGS+=("-quit-combo=\$QUIT_COMBO")

exec "${md_inst}/bin/${md_id}-run" "\${ARGS[@]}" "\$@"
_EOF_
        chmod +x "${md_inst}/${md_id}.sh"
    fi

    setConfigRoot ""

    moveConfigDir "${arpdir}/${md_id}" "${md_conf_root}/${md_id}/"

    addEmulator 1 "${md_id}" "${md_id}" "${md_inst}/${md_id}.sh %ROM%"

    addSystem "${md_id}"
}

function gui_solarus() {
    local options=()
    local default
    local cmd
    local choice
    local joypad_deadzone
    local quit_combo

    # Initialise Options Config File
    iniConfig "=" "\"" "$(_options_cfg_file_solarus)"

    # Start The Menu GUI
    default="D"
    while true; do
        # read current options
        iniGet "JOYPAD_DEADZONE" && joypad_deadzone="${ini_value}"
        iniGet "QUIT_COMBO" && quit_combo="${ini_value}"

        # Create Menu Options
        options=(
            D "Set joypad axis deadzone (${joypad_deadzone:-default})"
            Q "Set joypad quit buttons combo (${quit_combo:-unset})"
        )

        # Show Main Menu
        cmd=(dialog --backtitle "${__backtitle}" --default-item "${default}" --menu "Choose An Option" 16 60 16)
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        default="${choice}"
        case "${choice}" in
            D)
                cmd=(dialog --backtitle "${__backtitle}" --inputbox "Please enter a joypad axis deadzone value between 0-32767, higher is less sensitive (leave BLANK to use engine default)" 10 65)
                choice=$("${cmd[@]}" 2>&1 >/dev/tty)
                if [[ $? -eq 0 ]]; then
                    if [[ -n "${choice}" ]]; then
                        iniSet "JOYPAD_DEADZONE" "${choice}"
                    else
                        iniDel "JOYPAD_DEADZONE"
                    fi
                    chown "${user}:${user}" "$(_options_cfg_file_solarus)"
                fi
                ;;
            Q)
                cmd=(dialog --backtitle "${__backtitle}" --inputbox "Please enter joypad button numbers to use for quitting separated by '+' signs (leave BLANK to unset)\n\nTip: use 'jstest' to find button numbers for your joypad" 12 65)
                choice=$("${cmd[@]}" 2>&1 >/dev/tty)
                if [[ $? -eq 0 ]]; then
                    if [[ -n "${choice}" ]]; then
                        iniSet "QUIT_COMBO" "${choice}"
                    else
                        iniDel "QUIT_COMBO"
                    fi
                    chown "${user}:${user}" "$(_options_cfg_file_solarus)"
                fi
                ;;
            *)
                break
                ;;
        esac
    done
}
