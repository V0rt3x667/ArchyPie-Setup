#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="attractmode"
rp_module_desc="Attract-Mode: Emulator Frontend"
rp_module_licence="GPL3 https://raw.githubusercontent.com/mickelson/attract/master/License.txt"
rp_module_repo="git https://github.com/mickelson/attract master"
rp_module_section="exp"
rp_module_flags="frontend"

function _get_configdir_attractmode() {
    echo "${configdir}/all/attractmode"
}

function _add_system_attractmode() {
    local attract_dir

    attract_dir="$(_get_configdir_attractmode)"
    [[ ! -d "${attract_dir}" || ! -f "/usr/bin/attract" ]] && return 0

    local fullname="${1}"
    local name="${2}"
    local path="${3}"
    local extensions="${4}"
    local command="${5}"
    local platform="${6}"
    local theme="${7}"

    # Replace Any '/' Characters In Fullname
    fullname="${fullname//\/}"

    local config="${attract_dir}/emulators/${fullname}.cfg"
    iniConfig " " "" "${config}"
    # Replace %ROM% With "[romfilename]" & Convert To An Array
    # shellcheck disable=SC2206
    command=(${command//%ROM%/\"[romfilename]\"})
    iniSet "executable" "${command[0]}"
    iniSet "args" "${command[*]:1}"

    iniSet "rompath" "${path}"
    iniSet "system" "${fullname}"

    # Extensions Separated By Semicolons
    extensions="${extensions// /;}"

    iniSet "romext" "${extensions}"

    # Snap Path
    local snap="snap"
    [[ "${name}" == "archypie" ]] && snap="icons"
    iniSet "artwork flyer"   "${path}/flyer"
    iniSet "artwork marquee" "${path}/marquee"
    iniSet "artwork snap"    "${path}/${snap}"
    iniSet "artwork wheel"   "${path}/wheel"

    chown "${__user}":"${__group}" "${config}"

    # If No Gameslist, Generate One
    if [[ ! -f "${attract_dir}/romlists/${fullname}.txt" ]] && [[ -f "/usr/bin/attract" ]]; then
        sudo -u "${__user}" attract --build-romlist "${fullname}" -o "${fullname}"
    else
        return
    fi

    local config="${attract_dir}/attract.cfg"
    local tab=$'\t'
    if [[ -f "${config}" ]] && ! grep -q "display${tab}${fullname}" "${config}"; then
        cp "${config}" "${config}.bak"
        cat >>"${config}" <<_EOF_
display${tab}${fullname}
${tab}layout               Basic
${tab}romlist              ${fullname}
_EOF_
        chown "${__user}":"${__group}" "${config}"*
    fi
}

function _del_system_attractmode() {
    local attract_dir
    attract_dir="$(_get_configdir_attractmode)"
    [[ ! -d "${attract_dir}" ]] && return 0

    local fullname="${1}"
    local name="${2}"

    # Don't Remove An Empty System
    [[ -z "${fullname}" ]] && return 0

    # Replace Any '/' Characters In Fullname
    fullname="${fullname//\/}"

    rm -rf "${attract_dir}/romlists/${fullname}.txt"

    local tab=$'\t'
    # Remove Display Block From "^display${tab}${fullname}" To Next "^display" Or Empty Line Keeping The Next Display Line
    sed -i "/^display${tab}${fullname}/,/^display\|^$/{/^display${tab}${fullname}/d;/^display\$/!d}" "${attract_dir}/attract.cfg"
}

function _add_rom_attractmode() {
    local attract_dir
    attract_dir="$(_get_configdir_attractmode)"
    [[ ! -d "${attract_dir}" ]] && return 0

    local system_name="${1}"
    local system_fullname="${2}"
    local path="${3}"
    local name="${4}"
    local desc="${5}"
    local image="${6}"

    local config="${attract_dir}/romlists/${system_fullname}.txt"

    # Remove Extension
    path="${path/%.*}"

    if [[ ! -f "${config}" ]]; then
        echo "#Name;Title;Emulator;CloneOf;Year;Manufacturer;Category;Players;Rotation;Control;Status;DisplayCount;DisplayType;AltRomname;AltTitle;Extra;Buttons" >"${config}"
    fi

    # If The Entry Already Exists, Remove It
    if grep -q "^${path};" "${config}"; then
        sed -i "/^${path}/d" "${config}"
    fi

    echo "${path};${name};${system_fullname};;;;;;;;;;;;;;" >>"${config}"
    chown "${__user}":"${__group}" "${config}"
}

function depends_attractmode() {
    local depends=(
        'curl'
        'ffmpeg'
        'fontconfig'
        'gnu-free-fonts'
        'libarchive'
        'p7zip'
        'sfml'
    )
    isPlatform "kms" && depends+=(
        'glu'
        'libdrm'
        'libglvnd'
        'mesa'
    )
    isPlatform "x11" && depends+=('libxinerama')
    getDepends "${depends[@]}"
}

function sources_attractmode() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|/.attract|/ArchyPie/configs/${md_id}|g" -i "${md_build}/src/fe_settings.cpp"
}

function build_attractmode() {
    local params=('USE_SYSTEM_SFML=1')

    isPlatform "kms" && params+=('USE_DRM=1')
    isPlatform "rpi" && params+=('USE_MMAL=1')
    isPlatform "x11" && params+=('FE_HWACCEL_VAAPI=1' 'FE_HWACCEL_VDPAU=1')

    make clean
    make prefix="${md_inst}" "${params[@]}"

    # Remove Example Configs
    rm -rf "${md_build}/config/emulators/"*

    md_ret_require="${md_build}/attract"
}

function install_attractmode() {
    make prefix="${md_inst}" install
}

function remove_attractmode() {
    rm -f /usr/bin/attract
}

function configure_attractmode() {
    moveConfigDir "${arpdir}/${md_id}"  "${md_conf_root}/all/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        # Create Default Config File
        local config="${md_conf_root}/all/${md_id}/attract.cfg"

        if [[ ! -f "${config}" ]]; then
            echo "general" >"${config}"
            echo -e "\twindow_mode          fullscreen" >>"${config}"
        fi
        chown "${__user}":"${__group}" "${config}"

        mkUserDir "${md_conf_root}/all/${md_id}/emulators"

        # Create Launcher Script
        cat > "/usr/bin/attract" <<_EOF_
#!/usr/bin/env bash
MODELIST=/opt/archypie/supplementary/kmsxx/kmsprint-rp
if [[ -z "\${DISPLAY}" && -f "\${MODELIST}" && ! "\${1}" =~ build-romlist ]]; then
    MODELIST="\$(\${MODELIST} 2>/dev/null)"
    default_mode="\$(echo "\${MODELIST}" | grep -Em1 "^Mode: [0-9]+ crtc" | grep -oE [0-9]+x[0-9]+)"
    default_vrefresh="\$(echo "\${MODELIST}" | grep -Em1 "^Mode: [0-9]+ crtc" | grep -oE [0-9]+Hz)"
    # Strip Hz from the refresh rate
    default_vrefresh="\${default_vrefresh%Hz}"
    echo "Using default video mode: \${default_mode} @ \${default_vrefresh}"

    [[ ! -z "\${default_mode}" ]] && export SFML_DRM_MODE="\${default_mode}"
    [[ ! -z "\${default_vrefresh}" ]] && export SFML_DRM_REFRESH="\${default_vrefresh}"
fi
"${md_inst}/bin/attract" "\${@}"
_EOF_
        chmod +x "/usr/bin/attract"

        local id
        for id in "${__mod_id[@]}"; do
            if rp_isInstalled "${id}" && [[ -n "${__mod_info[${id}/section]}" ]] && ! hasFlag "${__mod_info[${id}/flags]}" "frontend"; then
                rp_callModule "${id}" configure
            fi
        done
    fi
}
