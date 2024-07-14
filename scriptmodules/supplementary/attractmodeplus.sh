#!/usr/bin/env bash

# This file is part of the ArchyPie project.
#
# Please see the LICENSE file at the top-level directory of this distribution.

rp_module_id="attractmodeplus"
rp_module_desc="Attract-Mode Plus: Emulator Frontend"
rp_module_licence="GPL3 https://raw.githubusercontent.com/oomek/attractplus/master/License.txt"
rp_module_repo="git https://github.com/oomek/attractplus :_get_branch_attractmodeplus"
rp_module_section="exp"
rp_module_flags="frontend"

function _get_branch_attractmodeplus() {
    download "https://api.github.com/repos/oomek/attractplus/releases/latest" - | grep -m 1 tag_name | cut -d\" -f4
}

function _get_configdir_attractmodeplus() {
    echo "${configdir}/all/attractmodeplus"
}

function _add_system_attractmodeplus() {
    local attractplus_dir

    attractplus_dir="$(_get_configdir_attractmodeplus)"
    [[ ! -d "${attractplus_dir}" || ! -f "/usr/bin/attractplus" ]] && return 0

    local fullname="${1}"
    local name="${2}"
    local path="${3}"
    local extensions="${4}"
    local command="${5}"
    local platform="${6}"
    local theme="${7}"

    # Replace Any '/' Characters In Fullname
    fullname="${fullname//\/}"

    local config="${attractplus_dir}/emulators/${fullname}.cfg"
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
    iniSet "artwork flyer" "${path}/flyer"
    iniSet "artwork marquee" "${path}/marquee"
    iniSet "artwork snap" "${path}/${snap}"
    iniSet "artwork wheel" "${path}/wheel"

    chown "${user}:${user}" "${config}"

    # If No Gameslist, Generate One
    if [[ ! -f "${attractplus_dir}/romlists/${fullname}.txt" ]] && [[ -f "/usr/bin/attractplus" ]]; then
        sudo -u "${user}" attractplus --build-romlist "${fullname}" -o "${fullname}"
    else
        return
    fi

    local config="${attractplus_dir}/attract.cfg"
    local tab=$'\t'
    if [[ -f "${config}" ]] && ! grep -q "display${tab}${fullname}" "${config}"; then
        cp "${config}" "${config}.bak"
        cat >>"${config}" <<_EOF_
display${tab}${fullname}
${tab}layout               Basic
${tab}romlist              ${fullname}
_EOF_
        chown "${user}:${user}" "${config}"*
    fi
}

function _del_system_attractmodeplus() {
    local attractplus_dir
    attractplus_dir="$(_get_configdir_attractmodeplus)"
    [[ ! -d "${attractplus_dir}" ]] && return 0

    local fullname="${1}"
    local name="${2}"

    # Don't Remove An Empty System
    [[ -z "${fullname}" ]] && return 0

    # Replace Any '/' Characters In Fullname
    fullname="${fullname//\/}"

    rm -rf "${attractplus_dir}/romlists/${fullname}.txt"

    local tab=$'\t'
    # Remove Display Block From "^display${tab}${fullname}" To Next "^display" Or Empty Line Keeping The Next Display Line
    sed -i "/^display${tab}${fullname}/,/^display\|^$/{/^display${tab}${fullname}/d;/^display\$/!d}" "${attractplus_dir}/attract.cfg"
}

function _add_rom_attractmodeplus() {
    local attractplus_dir
    attractplus_dir="$(_get_configdir_attractmodeplus)"
    [[ ! -d "${attractplus_dir}" ]] && return 0

    local system_name="${1}"
    local system_fullname="${2}"
    local path="${3}"
    local name="${4}"
    local desc="${5}"
    local image="${6}"

    local config="${attractplus_dir}/romlists/${system_fullname}.txt"

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
    chown "${user}:${user}" "${config}"
}

function depends_attractmodeplus() {
    local depends=(
        'cmake'
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

function sources_attractmodeplus() {
    gitPullOrClone

    # Set Default Config Path(s)
    sed -e "s|/.attract|/ArchyPie/configs/${md_id}|g" -i "${md_build}/src/fe_settings.cpp"

    # Fix FFMPEG
    applyPatch "${md_data}/01_fix_ffmpeg.patch"
}

function build_attractmodeplus() {
    local params=('STATIC=0')

    isPlatform "kms" && params+=('USE_DRM=1')
    isPlatform "x11" && params+=('FE_HWACCEL_VAAPI=1' 'FE_HWACCEL_VDPAU=1')

    make clean
    make prefix="${md_inst}" "${params[@]}"

    # Remove Example Configs
    rm -rf "${md_build}/config/emulators/"*

    md_ret_require="${md_build}/attractplus"
}

function install_attractmodeplus() {
    make prefix="${md_inst}" install
}

function remove_attractmodeplus() {
    rm -f /usr/bin/attractplus
}

function configure_attractmodeplus() {
    moveConfigDir "${arpdir}/${md_id}"  "${md_conf_root}/all/${md_id}"

    if [[ "${md_mode}" == "install" ]]; then
        # Create Default Config File
        local config="${md_conf_root}/all/${md_id}/attract.cfg"

        if [[ ! -f "${config}" ]]; then
            echo "general" >"${config}"
            echo -e "\twindow_mode          fullscreen" >>"${config}"
        fi
        chown "${user}:${user}" "${config}"

        mkUserDir "${md_conf_root}/all/${md_id}/emulators"

        # Create Launcher Script
        cat > "/usr/bin/attractplus" <<_EOF_
#!/bin/bash
"${md_inst}/bin/attractplus" "\${@}"
_EOF_
    chmod +x "/usr/bin/attractplus"

        local id
        for id in "${__mod_id[@]}"; do
            if rp_isInstalled "${id}" && [[ -n "${__mod_info[${id}/section]}" ]] && ! hasFlag "${__mod_info[${id}/flags]}" "frontend"; then
                rp_callModule "${id}" configure
            fi
        done
    fi
}
