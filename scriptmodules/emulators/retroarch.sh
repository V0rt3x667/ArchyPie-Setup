#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="retroarch"
rp_module_desc="RetroArch: Libretro Frontend (Required By All lr-* Cores)"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/RetroArch/master/COPYING"
rp_module_repo="git https://github.com/Libretro/RetroArch v1.14.0"
rp_module_section="core"

function depends_retroarch() {
    local depends=(
        'bearssl'
        'ffmpeg'
        'flac'
        'libass'
        'libcaca'
        'libusb'
        'libxkbcommon'
        'libxml2'
        'mbedtls'
        'mesa'
        'miniupnpc'
        'openal'
        'sdl2'
        'systemd-libs'
        'zlib'
    )
    isPlatform "gles" && depends+=('libglvnd')
    isPlatform "rpi" && depends+=('raspberrypi-firmware')
    isPlatform "x11" && depends+=(
        'libx11'
        'libxcb'
        'libxext'
        'libxinerama'
        'libxrandr'
        'libxv'
        'libxxf86vm'
    )
    isPlatform "x11" || isPlatform "wayland" && depends+=(
        'glslang'
        'libpulse'
        'spirv-tools'
        'wayland-protocols'
        'wayland'
    )
    isPlatform "vulkan" && depends+=('vulkan-icd-loader')
    getDepends "${depends[@]}"
}

function sources_retroarch() {
    gitPullOrClone
    local patchs=(
        '01_revert_default_paths.patch'
        '02_add_video_shader_parameter.patch'
    )
    for patch in "${patchs[@]}"; do
        applyPatch "${md_data}/${patch}"
    done
}

function build_retroarch() {
    local params=(
        --disable-builtinbearssl \
        --disable-builtinflac \
        --disable-builtinglslang \
        --disable-builtinmbedtls \
        --disable-builtinzlib \
        --disable-cg \
        --disable-discord \
        --disable-jack \
        --disable-materialui \
        --disable-opengl1 \
        --disable-oss \
        --disable-qt \
        --disable-roar \
        --disable-update_assets \
        --disable-update_cores \
        --enable-dbus \
        --enable-sdl2
    )
    isPlatform "arm" && params+=('--enable-floathard')
    isPlatform "gles" && params+=('--enable-opengles')
    isPlatform "gles3" && params+=('--enable-opengles3')
    isPlatform "gles31" && params+=('--enable-opengles3_1')
    isPlatform "gles32" && params+=('--enable-opengles3_2')
    isPlatform "mali" && params+=('--enable-mali_fbdev')
    isPlatform "neon" && params+=('--enable-neon')
    isPlatform "rpi" && params+=('--disable-videocore')
    isPlatform "rpi" && ! isPlatform "rpi4" && params+=('--disable-vulkan')
    isPlatform "wayland" && params+=(
        '--disable-x11'
        '--disable-xinerama'
        '--disable-xrandr'
        '--enable-egl'
        '--enable-kms'
        '--enable-wayland'
    )
    isPlatform "kms" && params+=(
        '--disable-wayland'
        '--disable-x11'
        '--disable-xinerama'
        '--disable-xrandr'
        '--enable-egl'
        '--enable-kms'
    )
    isPlatform "x11" && params+=('--enable-x11')
    isPlatform "vulkan" && params+=('--enable-vulkan')

    ./configure --prefix="${md_inst}" "${params[@]}"
    make clean
    make
    md_ret_require="${md_build}/${md_id}"
}

function install_retroarch() {
    make install
    md_ret_files=('retroarch.cfg')
}

function update_shaders-retropie_retroarch() {
    local dir="${configdir}/all/${md_id}/shaders"
    # Remove If Not A Git Repository And Do A Fresh Checkout
    [[ ! -d "${dir}/retropie/.git" ]] && rm -rf "${dir}/retropie"
    gitPullOrClone "${dir}/retropie" "https://github.com/RetroPie/common-shaders.git"
    chown -R "${user}:${user}" "${dir}"
}

function update_shaders-glsl_retroarch() {
    local dir="${configdir}/all/${md_id}/shaders"
    # Remove If Not A Git Repository And Do A Fresh Checkout
    [[ ! -d "${dir}/glsl/.git" ]] && rm -rf "${dir}/glsl"
    gitPullOrClone "${dir}/glsl" "https://github.com/libretro/glsl-shaders.git"
    chown -R "${user}:${user}" "${dir}"
}

function update_shaders-slang_retroarch() {
    local dir="${configdir}/all/${md_id}/shaders"
    # Remove If Not A Git Repository And Do A Fresh Checkout
    [[ ! -d "${dir}/slang/.git" ]] && rm -rf "${dir}/slang"
    gitPullOrClone "${dir}/slang" "https://github.com/libretro/slang-shaders.git"
    chown -R "${user}:${user}" "${dir}"
}

function update_overlays_retroarch() {
    local dir="${configdir}/all/${md_id}/overlay"
    # Remove If Not A Git Repository And Do A Fresh Checkout
    [[ ! -d "${dir}/.git" ]] && rm -rf "${dir}"
    gitPullOrClone "${dir}" "https://github.com/libretro/common-overlays.git"
    chown -R "${user}:${user}" "${dir}"
}

function update_joypad_autoconfigs_retroarch() {
    gitPullOrClone "${md_build}/autoconfigs" "https://github.com/libretro/${md_id}-joypad-autoconfig.git"
    cp -a "${md_build}/autoconfigs/." "${md_inst}/autoconfig-presets/"
}

function update_assets_retroarch() {
    local dir="${configdir}/all/${md_id}/assets"
    # Remove If Not A Git Repository And Do A Fresh Checkout
    [[ ! -d "${dir}/.git" ]] && rm -rf "${dir}"
    gitPullOrClone "${dir}" "https://github.com/libretro/${md_id}-assets.git"
    chown -R "${user}:${user}" "${dir}"
}

function update_core_info_retroarch() {
    local dir="${configdir}/all/${md_id}/cores"
    # Remove If Not A Git Repository And Do A Fresh Checkout
    [[ ! -d "${dir}/.git" ]] && rm -fr "${dir}"
    gitPullOrClone "${configdir}/all/${md_id}/cores" "https://github.com/libretro/libretro-core-info.git"
    # Add The Info Files For Cores And Configurations Not Available Upstream
    cp -f "${md_data}/"*.info "${configdir}/all/${md_id}/cores"
    chown -R "${user}:${user}" "${dir}"
}

function configure_retroarch() {
    [[ "${md_mode}" == "remove" ]] && return

    addUdevInputRules

    # Move And Symlink The RetroArch Configuration
    moveConfigDir "${home}/.config/${md_id}" "${configdir}/all/${md_id}"

    # Move And Symlink "${md_id}-joypads" Folder
    moveConfigDir "${configdir}/all/${md_id}-joypads" "${configdir}/all/${md_id}/autoconfig"

    # Move And Symlink Old Assets, Overlays And Shader Folders
    moveConfigDir "${md_inst}/assets" "${configdir}/all/${md_id}/assets"
    moveConfigDir "${md_inst}/overlays" "${configdir}/all/${md_id}/overlay"
    moveConfigDir "${md_inst}/shader" "${configdir}/all/${md_id}/shaders"

    # Install Assets
    update_assets_retroarch

    # Install Core Info Files
    update_core_info_retroarch

    # Install Joypad Autoconfig Presets
    update_joypad_autoconfigs_retroarch

    local config
    config="$(mktemp)"
    cp "${md_inst}/${md_id}.cfg" "${config}"

    # Query ES A/B Keyswap Configuration
    local es_swap="false"
    getAutoConf "es_swap_a_b" && es_swap="true"

    # Configure Default Options
    iniConfig " = " '"' "${config}"
    iniSet "cache_directory" "/tmp/${md_id}"
    iniSet "system_directory" "${biosdir}"
    iniSet "config_save_on_exit" "false"
    iniSet "video_aspect_ratio_auto" "true"
    iniSet "rgui_browser_directory" "${romdir}"
    iniSet "rgui_switch_icons" "false"

    if ! isPlatform "x86"; then
        iniSet "video_threaded" "true"
    fi

    iniSet "video_font_size" "24"
    iniSet "core_options_path" "${configdir}/all/${md_id}-core-options.cfg"
    iniSet "global_core_options" "true"
    iniSet "video_fullscreen" "true"

    # Enable Hotkey ("select" Button)
    iniSet "input_enable_hotkey" "nul"
    iniSet "input_exit_emulator" "escape"

    # Enable And Configure Rewind Feature
    iniSet "rewind_enable" "false"
    iniSet "rewind_buffer_size" "10"
    iniSet "rewind_granularity" "2"
    iniSet "input_rewind" "r"

    # Enable GPU Screenshots
    iniSet "video_gpu_screenshot" "true"

    # Enable And Configure Shaders
    iniSet "input_shader_next" "m"
    iniSet "input_shader_prev" "n"

    # Configure Keyboard Mappings
    iniSet "input_player1_a" "x"
    iniSet "input_player1_b" "z"
    iniSet "input_player1_y" "a"
    iniSet "input_player1_x" "s"
    iniSet "input_player1_start" "enter"
    iniSet "input_player1_select" "rshift"
    iniSet "input_player1_l" "q"
    iniSet "input_player1_r" "w"
    iniSet "input_player1_left" "left"
    iniSet "input_player1_right" "right"
    iniSet "input_player1_up" "up"
    iniSet "input_player1_down" "down"

    # Input Settings
    iniSet "input_autodetect_enable" "true"
    iniSet "auto_remaps_enable" "true"
    iniSet "input_joypad_driver" "udev"
    iniSet "all_users_control_menu" "true"
    iniSet "remap_save_on_exit" "false"

    # RGUI Menu By Default
    iniSet "menu_driver" "rgui"
    iniSet "rgui_aspect_ratio_lock" "2"

    # Hide Online Updater Menu Options And The Restart Option
    iniSet "menu_show_core_updater" "false"
    iniSet "menu_show_online_updater" "false"
    iniSet "menu_show_restart_retroarch" "false"

    # Disable The Search Action
    iniSet "menu_disable_search_button" "true"

    # Remove Some Options From Quick Menu
    iniSet "quick_menu_show_close_content" "false"
    iniSet "quick_menu_show_add_to_favorites" "false"
    iniSet "menu_show_overlays" "false"

    # Disable The Load Notification Message With Core And Game Info
    iniSet "menu_show_load_content_animation" "false"

    # Disable Unnecessary XMB Menu Tabs
    iniSet "xmb_show_add" "false"
    iniSet "xmb_show_history" "false"
    iniSet "xmb_show_images" "false"
    iniSet "xmb_show_music" "false"

    # Disable XMB Menu Driver Icon Shadows
    iniSet "xmb_shadows_enable" "false"

    # Swap A/B Buttons Based On ES Configuration
    iniSet "menu_swap_ok_cancel_buttons" "${es_swap}"

    # Enable "menu_unified_controls" By Default
    iniSet "menu_unified_controls" "true"

    # Disable "press twice to quit"
    iniSet "quit_press_twice" "false"

    # Enable Video Shaders
    iniSet "video_shader_enable" "true"

    copyDefaultConfig "${config}" "${configdir}/all/${md_id}.cfg"
    rm "${config}"

    # If No Menu_Driver Is Set Force RGUI As The Default Has Now Changed To XMB
    _set_config_option_retroarch "menu_driver" "rgui"

    # Set RGUI Aspect Ratio to "integer scaling" To Prevent Stretching
    _set_config_option_retroarch "rgui_aspect_ratio_lock" "2"

    # If No "menu_unified_controls" Is Set, Force It On So That Keyboard Player 1 Can Control
    # The RGUI Menu Which Is Important For Arcade Sticks That Map To Keyboard Inputs
    _set_config_option_retroarch "menu_unified_controls" "true"

    # Disable "quit_press_twice" On Existing Configs
    _set_config_option_retroarch "quit_press_twice" "false"

    # Enable Video Shaders On Existing Configs
    _set_config_option_retroarch "video_shader_enable" "true"

    # Keep All Core Options In A Single File
    _set_config_option_retroarch "global_core_options" "true"

    # Disable The Content Load Info Popup With Core And Game Info
    _set_config_option_retroarch "menu_show_load_content_animation" "false"

    # Disable Search Action
    _set_config_option_retroarch "menu_disable_search_button" "true"

    # Don't Save Input Remaps By Default
    _set_config_option_retroarch "remap_save_on_exit" "false"

    # Remapping Hack For Old 8bitdo Firmware
    addAutoConf "8bitdo_hack" 0
}

function keyboard_retroarch() {
    if [[ ! -f "${configdir}/all/${md_id}.cfg" ]]; then
        printMsgs "dialog" "No RetroArch Configuration File Found At ${configdir}/all/${md_id}.cfg"
        return
    fi
    local input
    local options
    local i=1
    local key=()
    while read -r input; do
        local parts=("${input}")
        key+=("${parts[0]}")
        options+=("${parts[0]}" "${i}" 2 "${parts[*]:2}" "${i}" 26 16 0)
        ((i++))
    done < <(grep "^[[:space:]]*input_player[0-9]_[a-z]*" "${configdir}/all/${md_id}.cfg")
    local cmd=(dialog --backtitle "${__backtitle}" --form "RetroArch Keyboard Configuration" 22 48 16)
    local choice
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "${choice}" ]]; then
        local value
        local values
        readarray -t values <<<"${choice}"
        iniConfig " = " "" "${configdir}/all/${md_id}.cfg"
        i=0
        for value in "${values[@]}"; do
            iniSet "${key[$i]}" "${value}" >/dev/null
            ((i++))
        done
    fi
}

function hotkey_retroarch() {
    iniConfig " = " '"' "${configdir}/all/${md_id}.cfg"
    local cmd=(dialog --backtitle "${__backtitle}" --menu "Choose The Desired Hotkey Behaviour" 22 76 16)
    local options=(1 "Hotkeys Enabled (Default)"
             2 "Press ALT To Enable Hotkeys"
             3 "Hotkeys Disabled. Press ESCAPE To Open RGUI")
    local choice
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "${choice}" ]]; then
        case "${choice}" in
            1)
                iniSet "input_enable_hotkey" "nul"
                iniSet "input_exit_emulator" "escape"
                iniSet "input_menu_toggle" "F1"
                ;;
            2)
                iniSet "input_enable_hotkey" "alt"
                iniSet "input_exit_emulator" "escape"
                iniSet "input_menu_toggle" "F1"
                ;;
            3)
                iniSet "input_enable_hotkey" "escape"
                iniSet "input_exit_emulator" "nul"
                iniSet "input_menu_toggle" "escape"
                ;;
        esac
    fi
}

function gui_retroarch() {
    while true; do
        local names=('overlays' 'assets')
        local dirs=('overlay' 'assets')
        local options=()
        local name
        local dir
        local i=1
        if isPlatform "rpi"; then
            names+=('shaders-retropie')
            dirs+=('shaders/retropie')
        else
            names+=('shaders-glsl' 'shaders-slang')
            dirs+=('shaders/glsl' 'shaders/slang')
        fi
        for name in "${names[@]}"; do
            if [[ -d "${configdir}/all/${md_id}/${dirs[i-1]}/.git" ]]; then
                options+=("${i}" "Manage ${name} (Installed)")
            else
                options+=("${i}" "Manage ${name} (Not Installed)")
            fi
            ((i++))
        done
        options+=(
            6 "Configure Keyboard For Use With RetroArch"
            7 "Configure Keyboard Hotkey Behaviour For RetroArch"
        )
        local cmd=(dialog --backtitle "${__backtitle}" --menu "Choose An Option" 22 76 16)
        local choice
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        case "${choice}" in
            1|2|3|4|5)
                name="${names[choice-1]}"
                dir="${dirs[choice-1]}"
                options=(1 "Install/Update ${name}" 2 "Uninstall ${name}" )
                cmd=(dialog --backtitle "${__backtitle}" --menu "Choose An Option For ${dir}" 12 40 06)
                choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

                case "${choice}" in
                    1)
                        "update_${name}_retroarch"
                        ;;
                    2)
                        rm -rf "${configdir}/all/${md_id}/${dir}"
                        ;;
                    *)
                        continue
                        ;;
                esac
                ;;
            6)
                keyboard_retroarch
                ;;
            7)
                hotkey_retroarch
                ;;
            *)
                break
                ;;
        esac
    done
}

# Adds A RetroArch Global Config Option In "${configdir}/all/${md_id}.cfg", If Not Already Set
function _set_config_option_retroarch() {
    local option="$1"
    local value="$2"
    iniConfig " = " "\"" "${configdir}/all/${md_id}.cfg"
    iniGet "${option}"
    if [[ -z "${ini_value}" ]]; then
        iniSet "${option}" "${value}"
    fi
}
